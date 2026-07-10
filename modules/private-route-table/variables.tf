variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  type        = string
}

variable "common_tags" {
  description = "Common Resource Tags"
  type        = map(string)
}