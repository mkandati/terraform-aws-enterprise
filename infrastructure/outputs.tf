output "project_name" {
  description = "Project Name"
  value       = var.project_name
}

output "environment" {
  description = "Deployment Environment"
  value       = var.environment
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr
}