output "listener_arn" {
  description = "Listener ARN"
  value       = aws_lb_listener.this.arn
}

output "listener_id" {
  description = "Listener ID"
  value       = aws_lb_listener.this.id
}