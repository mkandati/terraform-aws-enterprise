#########################################
# Security Group
#########################################

resource "aws_security_group" "this" {

  name        = "${var.project_name}-${var.environment}-${var.security_group_name}"
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.security_group_name}"
    }
  )
}

#########################################
# Ingress Rules
#########################################

resource "aws_vpc_security_group_ingress_rule" "this" {

  for_each = {
    for index, rule in var.ingress_rules :
    index => rule
  }

  security_group_id            = aws_security_group.this.id
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = try(each.value.source_security_group_id, null)
  description                  = each.value.description
}

#########################################
# Egress Rule
#########################################

resource "aws_vpc_security_group_egress_rule" "all" {

  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

}