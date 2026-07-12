variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
variable "cpu_threshold" {
  type    = number
  default = 80
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group Name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN Suffix used for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN Suffix used for CloudWatch metrics"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}