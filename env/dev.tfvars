name = "dev"
region = "us-east-1"
cidr   = "10.0.0.0/16"
bastion_ami  = "ami-053b0d53c279acc90"
bastion_instance_type = "t2.micro"

asg_image_id      = "ami-053b0d53c279acc90"
asg_instance_type = "t3.micro"

azs                = ["us-east-1a", "us-east-1b"]
private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
public_subnets     = ["10.0.30.0/24", "10.0.40.0/24"]
database_subnets   = ["10.0.50.0/24", "10.0.60.0/24"]