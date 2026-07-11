#########################################
# EC2 Assume Role Policy
#########################################

data "aws_iam_policy_document" "ec2_assume_role" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

#########################################
# IAM Role
#########################################

resource "aws_iam_role" "this" {

  name = "${var.project_name}-${var.environment}-${var.role_name}"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.role_name}"
    }
  )
}

#########################################
# Attach Managed Policies
#########################################

resource "aws_iam_role_policy_attachment" "managed" {

  for_each = toset(var.managed_policy_arns)

  role = aws_iam_role.this.name

  policy_arn = each.value
}

#########################################
# Instance Profile
#########################################

resource "aws_iam_instance_profile" "this" {

  name = "${var.project_name}-${var.environment}-${var.role_name}"

  role = aws_iam_role.this.name
}