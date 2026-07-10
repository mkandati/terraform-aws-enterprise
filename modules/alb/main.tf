resource "aws_lb" "this" {

  name               = "${var.project_name}-${var.environment}-alb"
  internal           = var.internal
  load_balancer_type = "application"

  security_groups = [
    var.security_group_id
  ]

  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.deletion_protection
  idle_timeout               = var.idle_timeout

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }

  )

}