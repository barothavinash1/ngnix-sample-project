name = "prd"
region = "us-east-1"
cidr   = ["11.0.0.0/16"]
azs                = ["us-east-1a", "us-east-1b"]
private_subnets    = ["11.0.10.0/24", "11.0.20.0/24"]
public_subnets     = ["11.0.30.0/24", "11.0.40.0/24"]
database_subnets   = ["11.0.50.0/24", "11.0.60.0/24"]