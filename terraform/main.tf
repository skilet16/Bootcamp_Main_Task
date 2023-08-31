# Specify the required AWS provider and Terraform version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Get the latest ubuntu 22.04 version from the IAM  
data "aws_ami" "latest_ubuntu" {
    owners = ["099720109477"] 
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

# Create a security group for the ec2 instance
resource "aws_security_group" "security_group" {
   name = "WebServer Security Group - Eriks"
   vpc_id = var.vpc_id
   description = "Security group for main task"

   # Set inbound rules, open specific ports
   dynamic "ingress" {
    for_each = var.allow_ports
    content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   }

   # Set outbound rules, allow all tcp connections
   egress {
     from_port = 0
     to_port = 65535
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
 
   tags = var.common_tags
 }

# Create SSH key
resource "tls_private_key" "webserver_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create key pair using public key
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.webserver_key.public_key_openssh
}

# Create EC2 instance
resource "aws_instance" "ec2_instance" {
    depends_on = [aws_key_pair.generated_key]

    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instance_type
    key_name   = var.key_pair_name
    vpc_security_group_ids = [aws_security_group.security_group.id]

    tags = var.common_tags
}

# Save private key to the .pem file
resource "local_file" "key_pair_file" {
  filename = "../${var.key_pair_path}${var.key_pair_name}.pem"
  content = tls_private_key.webserver_key.private_key_pem
  file_permission = "0400"
}

# Save public ip address to the inventory file
resource "local_file" "inventory_file" {
  content = "[webserver]\n${aws_instance.ec2_instance.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.key_pair_name}.pem"
  filename = "../${var.inventory_path}"
}
