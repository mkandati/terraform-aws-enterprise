variable "region" {
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