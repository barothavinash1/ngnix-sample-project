# Data source to fetch the secret value
data "aws_secretsmanager_secret_version" "rdsadmin_password" {
  secret_id = "rdsadmin_password" # Replace with your Secrets Manager secret ID
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


locals {

  rdsadmin_password = data.aws_secretsmanager_secret_version.rdsadmin_password.secret_string
  asg_image_id      = var.asg_image_id
  asg_instance_type = var.asg_instance_type

}