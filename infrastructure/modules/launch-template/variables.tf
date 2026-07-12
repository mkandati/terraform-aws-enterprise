variable "instance_type" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "root_volume_size" {
  type = number
}

variable "enable_detailed_monitoring" {
  type = bool
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