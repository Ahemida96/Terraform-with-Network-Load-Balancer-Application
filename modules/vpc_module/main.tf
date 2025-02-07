resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = var.vpc_name
  }
}

locals {
  len_public_subnets  = length(var.public_subnets)
  len_private_subnets = length(var.private_subnets)
}

resource "aws_subnet" "public-subnet" {
  count                   = local.len_public_subnets > 0 && local.len_public_subnets >= length(var.availability_zones) ? local.len_public_subnets : 0
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_names[count.index] != "" ? var.public_subnet_names[count.index] : "Public Subnet ${count.index + 1}"
  }

}

resource "aws_route_table" "public" {
  count  = local.len_public_subnets > 0 && local.len_public_subnets >= length(var.availability_zones) ? local.len_public_subnets : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "Public Route Table ${count.index + 1}"
  }

}

resource "aws_route_table_association" "public" {
  count          = local.len_public_subnets > 0 && local.len_public_subnets >= length(var.availability_zones) ? local.len_public_subnets : 0
  subnet_id      = element(aws_subnet.public-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, count.index)
}

resource "aws_route" "public-internet-gateway" {
  count                  = local.len_public_subnets > 0 && local.len_public_subnets >= length(var.availability_zones) ? local.len_public_subnets : 0
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}


resource "aws_subnet" "private-subnet" {
  count                   = local.len_private_subnets > 0 && local.len_private_subnets >= length(var.availability_zones) ? local.len_private_subnets : 0
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.private_subnets, [""]), count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnet_names[count.index] != "" ? var.private_subnet_names[count.index] : "Private Subnet ${count.index + 1}"
  }
}

resource "aws_route_table" "private" {
  count  = local.len_private_subnets > 0 && local.len_private_subnets >= length(var.availability_zones) ? local.len_private_subnets : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "Private Route Table ${count.index + 1}"
  }

}

resource "aws_route_table_association" "private" {
  count          = local.len_private_subnets > 0 && local.len_private_subnets >= length(var.availability_zones) ? local.len_private_subnets : 0
  subnet_id      = element(aws_subnet.private-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

resource "aws_route" "private-nat-gateway" {
  count                  = local.len_private_subnets > 0 && local.len_private_subnets >= length(var.availability_zones) ? local.len_private_subnets : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_eip" "this" {
  count      = local.len_private_subnets > 0 && local.len_private_subnets >= length(var.availability_zones) ? local.len_private_subnets : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = local.len_public_subnets > 0 && local.len_public_subnets >= length(var.availability_zones) ? local.len_public_subnets : 0
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id
}
