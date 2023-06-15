

module "nginx_vpc" {
  source = "./modules/vpc"

  name = "${var.name}-nginx-vpc"
  cidr = var.cidr

  azs                = var.azs
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  database_subnets   = var.database_subnets
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    provisioner = "Terraform"
    Environment = "${var.name}"
  }
}


module "db_security_group" {
  source = "./modules/sg"

  name        = "${var.name}-nginxrds-sg"
  description = "RDS-SG"
  vpc_id      = module.nginx_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Mysql access from within VPC"
      cidr_blocks = module.nginx_vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = ""
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = {
    provisioner = "Terraform"
    Environment = "${var.name}"
  }
}

module "ec2_security_group" {
  source = "./modules/sg"

  name        = "${var.name}-nginxec2-sg"
  description = "RDS-SG"
  vpc_id      = module.nginx_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Mysql access from within VPC"
      cidr_blocks = module.nginx_vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = ""
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = {
    provisioner = "Terraform"
    Environment = "${var.name}"
  }
}

module "bastion_security_group" {
  source = "./modules/sg"

  name        = "${var.name}-nginxbastion-sg"
  description = "BASTION-SG"
  vpc_id      = module.nginx_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
      cidr_blocks = "${chomp(data.http.myip.body)}/32"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = ""
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = {
    provisioner = "Terraform"
    Environment = "${var.name}"
  }
}

module "lb_security_group" {
  source = "./modules/sg"

  name        = "${var.name}-nginxlb-sg"
  description = "LB-SG"
  vpc_id      = module.nginx_vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access from outside"
      cidr_blocks = "${chomp(data.http.myip.body)}/32"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = ""
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = {
    provisioner = "Terraform"
    Environment = "${var.name}"
  }
}


module "nginx_alb" {
  source = "./modules/alb"

  name = "${var.name}-nginx-alb"

  vpc_id          = module.nginx_vpc.vpc_id
  subnets         = module.nginx_vpc.public_subnets
  security_groups = [module.lb_security_group.security_group_id]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "${var.name}-nginxlb-targetgp"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  tags = {
    provisioner = "Terraform"
    Environment = "${var.name}"
  }
}


module "nginx_mysqldb" {
  source = "./modules/mysqldb"

  identifier = "${var.name}-nginx-mysqldb"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.m5d.large"
  allocated_storage = 5

  db_name  = "nginxwebdb"
  username = "dbadmin"
  password = local.rdsadmin_password
  port     = "3306"

  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [module.db_security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "${var.name}-MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {

    provisioner = "Terraform"
    Environment = "${var.name}"

  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.nginx_vpc.database_subnets

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}