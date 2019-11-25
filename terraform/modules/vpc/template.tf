# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Subnets
resource "aws_subnet" "public-1-sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.env}-public-1-sn"
  }
}

resource "aws_subnet" "public-2-sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "${var.env}-public-2-sn"
  }
}
resource "aws_subnet" "public-3-sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2c"

  tags = {
    Name = "${var.env}-public-3-sn"
  }
}
resource "aws_subnet" "private-1-sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.env}-private-1-sn"
  }
}
resource "aws_subnet" "private-2-sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "${var.env}-private-2-sn"
  }
}
resource "aws_subnet" "private-3-sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2c"

  tags = {
    Name = "${var.env}-private-3-sn"
  }
}

# Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.env}-igw"
  }
}

# route tables
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.env}-public-rt"
  }
}

# route associations public
resource "aws_route_table_association" "public-1-rt-association" {
  subnet_id      = "${aws_subnet.public-1-sn.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-2-rt-association" {
  subnet_id      = "${aws_subnet.public-2-sn.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-3-rt-association" {
  subnet_id      = "${aws_subnet.public-3-sn.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

# nat gw
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-1-sn.id}"
  depends_on    = ["aws_internet_gateway.igw"]

  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = {
    Name = "${var.env}-private-rt"
  }
}

# Associating route table with private subnets
resource "aws_route_table_association" "private-1-rt-association" {
  subnet_id      = "${aws_subnet.private-1-sn.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-2-rt-association" {
  subnet_id      = "${aws_subnet.private-2-sn.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-3-rt-association" {
  subnet_id      = "${aws_subnet.private-3-sn.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

