resource "aws_cloudwatch_log_group" "application" {

  name              = "/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-application-logs"
    }
  )
}

resource "aws_cloudwatch_dashboard" "infrastructure" {

  dashboard_name = "${var.project_name}-${var.environment}-infrastructure"

  dashboard_body = jsonencode({

    widgets = [

      # ---------------------------------------------------------------------
      # ALB - Request Count
      # ---------------------------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "ALB Request Count"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          stat    = "Sum"
          period  = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      },

      # ---------------------------------------------------------------------
      # ALB - Healthy Host Count
      # ---------------------------------------------------------------------
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Healthy Host Count"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              var.target_group_arn_suffix,
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      },

      # ---------------------------------------------------------------------
      # ALB - Target Response Time
      # ---------------------------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Target Response Time"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "TargetGroup",
              var.target_group_arn_suffix,
              "LoadBalancer",
              var.alb_arn_suffix
            ]
          ]
        }
      },

      # ---------------------------------------------------------------------
      # Auto Scaling - Desired Capacity
      # ---------------------------------------------------------------------
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ASG Desired Capacity"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/AutoScaling",
              "GroupDesiredCapacity",
              "AutoScalingGroupName",
              var.autoscaling_group_name
            ]
          ]
        }
      },

      # ---------------------------------------------------------------------
      # Auto Scaling - In Service Instances
      # ---------------------------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "ASG InService Instances"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/AutoScaling",
              "GroupInServiceInstances",
              "AutoScalingGroupName",
              var.autoscaling_group_name
            ]
          ]
        }
      }

    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {

  alarm_name        = "${var.project_name}-${var.environment}-unhealthy-hosts"
  alarm_description = "Triggers when healthy targets fall below 2"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HealthyHostCount"

  statistic = "Average"

  period = 60

  evaluation_periods = 2

  threshold = 2

  comparison_operator = "LessThanThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [
    var.sns_topic_arn
  ]

  ok_actions = [
    var.sns_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "target_response_time" {

  alarm_name        = "${var.project_name}-${var.environment}-target-response-time"
  alarm_description = "ALB target response time is too high"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  statistic = "Average"
  period    = 60

  evaluation_periods  = 2
  threshold           = 2
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [
    var.sns_topic_arn
  ]

  ok_actions = [
    var.sns_topic_arn
  ]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target_5xx_errors" {

  alarm_name        = "${var.project_name}-${var.environment}-target-5xx-errors"
  alarm_description = "Application is returning HTTP 5XX errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  statistic = "Sum"
  period    = 60

  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  alarm_actions = [
    var.sns_topic_arn
  ]

  ok_actions = [
    var.sns_topic_arn
  ]

  treat_missing_data = "notBreaching"
}