#########################################
# Private Route Table
#########################################

resource "aws_route_table" "private" {

  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt"
    }
  )
}

#########################################
# Default Route to NAT Gateway
#########################################

resource "aws_route" "nat_gateway" {

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.nat_gateway_id
}

#########################################
# Associate Private Subnets
#########################################

resource "aws_route_table_association" "private" {

  count = length(var.private_subnet_ids)

  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}