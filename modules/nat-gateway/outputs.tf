output "nat_gateway_id" {

  description = "NAT Gateway ID"

  value = aws_nat_gateway.this.id

}

output "elastic_ip" {

  description = "Elastic IP Address"

  value = aws_eip.nat.public_ip

}