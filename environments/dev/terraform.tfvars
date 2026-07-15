#######################################
# AWS Configuration
#######################################

aws_region = "ap-south-1"

#######################################
# Project Details
#######################################

project_name = "enterprise-network"
environment  = "dev"

#######################################
# Networking
#######################################

vpc_cidr = "10.0.0.0/16"

enable_dns_support   = true
enable_dns_hostnames = true

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

managed_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
]

instance_type              = "t2.micro"
root_volume_size           = 30
enable_detailed_monitoring = true
ami_id                     = "ami-0458b73889d64ef2a"

notification_email = "mukandat456@gmail.com"