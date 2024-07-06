resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name   = "${var.entity}-${var.environment}-VPC"
    qcs-use = "main-vpc"
  }
}
resource "aws_subnet" "public-subnet-1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = "${var.region}a"
  tags = {
    Name   = "${var.entity}-${var.environment}-Public-Subnet-1"
    qcs-use = "public-subnet1"
  }
}
resource "aws_subnet" "public-subnet-2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = "${var.region}b" #may need to change for eu-west-2 during apply usually b
  tags = {
    Name   = "${var.entity}-${var.environment}-Public-Subnet-2"
    qcs-use = "public-subnet2"
  }
}
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name   = "${var.entity}-${var.environment}-Public-RouteTable"
    qcs-use = "public-routetable"
  }
}
resource "aws_route_table_association" "public-route-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}
resource "aws_route_table_association" "public-route-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-2.id
}
resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = "${var.region}a"
  tags = {
    Name   = "${var.entity}-${var.environment}-Private-Subnet-1"
    qcs-use = "private-subnet1"
  }
}
resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = "${var.region}b" #may need to change for eu-west-2 during apply usually b
  tags = {
    Name   = "${var.entity}-${var.environment}-Private-Subnet-2"
    qcs-use = "private-subnet2"
  }
}
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name   = "${var.entity}-${var.environment}-Private-RouteTable"
    qcs-use = "private-routetable"
  }
}
resource "aws_route_table_association" "private-route-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1.id
}
resource "aws_route_table_association" "private-route-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-2.id
}
resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true
  associate_with_private_ip = var.nat_gw_eip

  tags = {
    Name = "${var.entity}-${var.environment}-EIP"
  }
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name   = "${var.entity}-${var.environment}-NATGW"
    qcs-use = "nat-gw"
  }
  # Per tf provider page, To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main-igw] #added depends on igw and removed destinationcidrblock for public natgw
}
resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
  timeouts {
    create = "5m"
  }
}
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name   = "${var.entity}-${var.environment}-IGW"
    qcs-use = "main-igw"
  }
}
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.main-igw.id
  destination_cidr_block = "0.0.0.0/0"
}