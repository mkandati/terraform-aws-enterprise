resource "aws_launch_template" "this" {

  name_prefix = "${var.project_name}-${var.environment}-lt-"

  image_id               = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  update_default_version = true

  vpc_security_group_ids = [
    var.security_group_id
  ]

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(file("${path.module}/user_data.sh"))

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {

    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {

    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-ec2"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-launch-template"
    }
  )
}