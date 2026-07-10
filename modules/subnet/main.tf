#########################################
# Get Available Availability Zones
#########################################

data "aws_availability_zones" "available" {
  state = "available"
}

#########################################
# Public Subnets
#########################################

resource "aws_subnet" "public" {

  count = length(var.public_subnet_cidrs)

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Tier = "Public"
    }
  )
}

#########################################
# Private Subnets
#########################################

resource "aws_subnet" "private" {

  count = length(var.private_subnet_cidrs)

  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      Tier = "Private"
    }
  )
}