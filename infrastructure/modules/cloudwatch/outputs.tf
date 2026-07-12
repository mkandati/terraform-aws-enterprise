output "log_group_name" {
  value = aws_cloudwatch_log_group.application.name
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.infrastructure.dashboard_name
}