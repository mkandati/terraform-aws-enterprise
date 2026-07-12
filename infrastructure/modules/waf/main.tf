resource "aws_wafv2_web_acl" "this" {

  name  = "${var.project_name}-${var.environment}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {

    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {

      managed_rule_group_statement {

        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

      }
    }

    visibility_config {

      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-common-rule-set"
      sampled_requests_enabled   = true

    }

  }

  visibility_config {

    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-web-acl"
    sampled_requests_enabled   = true

  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-web-acl"
    }
  )
}

resource "aws_wafv2_web_acl_association" "alb" {

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn

}