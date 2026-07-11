variable "target_group_arn" {
  description = "Target Group ARN"
  type        = string
}

variable "target_id" {
  description = "EC2 Instance ID"
  type        = string
}

variable "port" {
  description = "Target Port"
  type        = number
  default     = 80
}