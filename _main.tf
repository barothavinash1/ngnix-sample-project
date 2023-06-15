

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
      from_port   = 80
      to_port     = 80
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
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access from outside"
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