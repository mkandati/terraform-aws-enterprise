resource "aws_lb_target_group" "this" {

  name = "${var.project_name}-${var.environment}-tg"

  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled  = true
    path     = var.health_check_path
    protocol = var.health_check_protocol
    matcher  = var.health_check_matcher

    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-tg"
    }
  )
}