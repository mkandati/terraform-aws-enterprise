# ALB Module

## Purpose

Creates a production-ready AWS Application Load Balancer.

## Resources

- Application Load Balancer

## Inputs

- project_name
- environment
- vpc_id
- public_subnet_ids
- security_group_id
- internal
- deletion_protection
- idle_timeout
- common_tags

## Outputs

- alb_arn
- alb_dns_name
- alb_zone_id
- alb_id