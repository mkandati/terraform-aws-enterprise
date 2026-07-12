output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "alb_id" {
  value = aws_lb.this.id
}

output "alb_arn_suffix" {
  description = "ARN suffix for CloudWatch metrics"
  value       = aws_lb.this.arn_suffix
}