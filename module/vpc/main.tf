provider "aws" {
  region = var.region
}

resource "aws_vpc" "network" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "3-TIER-VPC-NETWORK"
  }

}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.network.id

  count             = length(var.public_cidr)
  cidr_block        = var.public_cidr[count.index].cidr
  availability_zone = var.public_cidr[count.index].az

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index + 1}",
    AZ   = "${var.public_cidr[count.index].az}"
  }

}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.network.id

  count             = length(var.private_cidr)
  cidr_block        = var.private_cidr[count.index].cidr
  availability_zone = var.private_cidr[count.index].az


  tags = {
    Name = "private_subnet_${count.index + length(var.public_cidr) + 1}"
  }

}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.network.id

  tags = {
    Name = "3-TIER-IGW"
  }

}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name = "3-TIER-PUBLIC-ROUTE"
  }

}

resource "aws_nat_gateway" "nat_gate" {
  vpc_id            = aws_vpc.network.id
  availability_mode = "regional"
  connectivity_type = "public"

  tags = {
    Name = "3-TIER-NAT-GATEWAY"
  }


}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gate.id
  }

  tags = {
    Name = "3-TIER-PRIVATE-ROUTE"
  }

}

resource "aws_route_table_association" "public_association" {
  count          = length(var.public_cidr)
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnet[count.index].id

}

resource "aws_route_table_association" "private_association" {
  count          = length(var.private_cidr)
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet[count.index].id

}

