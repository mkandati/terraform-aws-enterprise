variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "enterprise-network"
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "managed_policy_arns" {
  description = "Managed IAM Policies"
  type        = list(string)
}

variable "instance_type" {
  type = string
}

variable "root_volume_size" {
  description = "Root EBS volume size"
  type        = number
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring"
  type        = bool
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "notification_email" {
  description = "Email address to receive CloudWatch alerts"
  type        = string
}