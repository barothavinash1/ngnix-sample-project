output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.nginx_vpc.vpc_cidr_block
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.nginx_vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.nginx_vpc.public_subnets_cidr_blocks
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.nginx_vpc.database_subnets_cidr_blocks
}



