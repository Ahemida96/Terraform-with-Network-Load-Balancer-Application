output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets_id" {
  value = aws_subnet.public-subnet[*].id
}

output "private_subnets_id" {
  value = aws_subnet.private-subnet[*].id
}

output "all_subnets_id" {
  value = concat(aws_subnet.public-subnet[*].id, aws_subnet.private-subnet[*].id)

}

output "availability_zones" {
  value = var.availability_zones

}
