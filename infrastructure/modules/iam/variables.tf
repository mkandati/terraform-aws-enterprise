variable "role_name" {
  description = "IAM Role Name"
  type        = string
}

variable "managed_policy_arns" {
  description = "List of managed IAM policies"

  type = list(string)
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