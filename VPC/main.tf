#setup VPC
resource "aws_vpc" "us-east-1_vpc" {
  cidr_block = ""

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = var.vpc_name
  }
}

#setup public subnet

resource "aws_subnet" "dev_proj_1_public_subnets" {
  vpc_id                  = aws_vpc.us-east-1_vpc.id
  cidr_block              = var.cidr_public_subnet
  availability_zone       = var.us_availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-proj-public-subnet-${count.index + 1}"
  }
}

#setup private subnet
resource "aws_subnet" "dev_proj_1_private_subnets" {
  count                   = length((var.cidr_public_subnet))
  vpc_id                  = aws_vpc.us-east-1_vpc.id
  cidr_block              = var.cidr_private_subnet
  availability_zone       = var.us_availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "dev-proj-private-subnet-${count.index + 1}"
  }
}

#setup internet gateway
resource "aws_internet_gateway" "dev_proj_1_igw" {
  vpc_id = aws_vpc.us-east-1_vpc.id
  tags = {
    Name = "Demo-VPC_IGW"
  }
}

#setup NAT gateway
resource "aws_nat_gateway" "nat-gateway" {
  subnet_id = aws_subnet.dev_proj_1_private_subnets[count.index].id
}


#setup public route table
resource "aws_route_table" "dev_proj_1_public_route_table" {
  vpc_id = aws_vpc.us-east-1_vpc.id
  route = {
    cidr_block           = "0.0.0.0/0"
    aws_internet_gateway = aws_internet_gateway.dev_proj_1_igw.id
  }

}

#setup route between public route table and public subnet
resource "aws_route_table_association" "dev_proj_1_public_route_associtation" {
  subnet_id      = aws_subnet.dev_proj_1_public_subnets.id
  route_table_id = aws_route_table.dev_proj_1_public_route_table.id

}

#setup private subnet
resource "aws_subnet" "dev_proj_1_private_subnet" {
  vpc_id                  = aws_vpc.us-east-1_vpc.id
  cidr_block              = var.cidr_private_subnet
  availability_zone       = var.us_availability_zone
  map_public_ip_on_launch = false

}


#private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.us-east-1_vpc.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
}

resource "aws_default_network_acl" "public" {
  default_network_acl_id = aws_vpc.us-east-1_vpc.default_network_acl_id
  subnet_ids             = [aws_subnet.dev_proj_1_public_subnets[count.index].id]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.us-east-1_vpc.id
  subnet_ids = [aws_subnet.dev_proj_1_private_subnets]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}