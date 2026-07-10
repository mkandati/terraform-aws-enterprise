#######################################
# Elastic IP
#######################################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip"
    }
  )
}

#######################################
# NAT Gateway
#######################################

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = var.public_subnet_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-gateway"
    }
  )

  depends_on = [
    aws_eip.nat
  ]

}