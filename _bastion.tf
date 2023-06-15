# Create an Elastic IP
resource "aws_eip" "bastion_eip" {
  depends_on = [module.nginx_vpc]
  vpc = true
}


# Create an EC2 instance
resource "aws_instance" "bastion_instance" {
  ami                         = var.bastion_ami # Replace with the latest Ubuntu AMI ID
  instance_type               = var.bastion_instance_type            # Set your desired instance type here
  subnet_id                   = module.nginx_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.bastion_security_group.security_group_id]
  key_name                    = "bastion" # Replace with your EC2 key pair
  associate_public_ip_address = true

  tags = {
    Name        = "nginx-bastion"
    provisioner = "Terraform"
    Environment = "${var.name}"

  }

  depends_on = [module.nginx_vpc]
}

# Associate the Elastic IP with the instance
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion_instance.id
  allocation_id = aws_eip.bastion_eip.id
}