
module "nginx_asg" {
  source = "./modules/asg"

  # Autoscaling group
  name = "${var.name}-nginx-web-asg"

  min_size                        = 0
  max_size                        = 2
  desired_capacity                = 2
  wait_for_capacity_timeout       = 0
  health_check_type               = "EC2"
  use_name_prefix                 = false
  launch_template_use_name_prefix = false
  vpc_zone_identifier             = module.nginx_vpc.private_subnets
  target_group_arns               = module.nginx_alb.target_group_arns
  user_data                       = filebase64("user_data.sh")

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.ec2_security_group.security_group_id]
    },
  ]

  initial_lifecycle_hooks = [
    {
      name                  = "ExampleStartupLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 60
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "ExampleTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "${var.name}-nginx-asg-lt"
  launch_template_description = "${var.name}-nginx-asg-lt"
  update_default_version      = true

  image_id          = local.asg_image_id
  instance_type     = local.asg_instance_type
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "${var.name}-asg-role"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role example"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    }
  ]

  tags = {
    provisioner = "Terraform"
    Environment = "dev"
  }
}


# Create a CloudWatch metric alarm for CPU utilization scale-up
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.name}-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "65" # Adjust the threshold value as needed
  alarm_description   = "Scale-up when CPU exceeds 80% for 2 consecutive periods"

  dimensions = {
    AutoScalingGroupName = module.nginx_asg.autoscaling_group_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
}

# Create a CloudWatch metric alarm for CPU utilization scale-down
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.name}-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "40" # Adjust the threshold value as needed
  alarm_description   = "Scale-down when CPU is below 20% for 2 consecutive periods"

  dimensions = {
    AutoScalingGroupName = module.nginx_asg.autoscaling_group_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
}

# Create a scale-up policy
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   ="${var.name}-scale-up-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  autoscaling_group_name = module.nginx_asg.autoscaling_group_name
}

# Create a scale-down policy
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "${var.name}-scale-down-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  autoscaling_group_name = module.nginx_asg.autoscaling_group_name
}
