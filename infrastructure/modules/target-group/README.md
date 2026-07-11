# Target Group Module

## Purpose

Creates an AWS Application Load Balancer Target Group.

## Resources

- aws_lb_target_group

## Inputs

- project_name
- environment
- vpc_id
- port
- protocol
- target_type
- health_check_path
- common_tags

## Outputs

- target_group_arn
- target_group_name
- target_group_id