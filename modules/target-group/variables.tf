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

variable "port" {
  description = "Target Group Port"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target Type"
  type        = string
  default     = "instance"
}

variable "health_check_path" {
  description = "Health Check Path"
  type        = string
  default     = "/"
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
}

variable "deregistration_delay" {
  description = "Time in seconds to wait before deregistering a target"
  type        = number
  default     = 300
}

variable "health_check_matcher" {
  description = "Expected HTTP response code for health checks"
  type        = string
  default     = "200"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "protocol" {
  description = "Target Group Protocol"
  type        = string
  default     = "HTTP"
}