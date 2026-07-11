variable "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the Target Group"
  type        = string
}

variable "port" {
  description = "Listener Port"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Listener Protocol"
  type        = string
  default     = "HTTP"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}