variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}

variable "internal" {
  description = "Internal Load Balancer"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable Deletion Protection"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Idle Timeout"
  type        = number
  default     = 60
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
}