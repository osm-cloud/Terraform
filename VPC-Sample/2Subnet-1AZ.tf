# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "<env>-vpc"
  }
}

#Subnet

#Public Subnet
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-a"
  }
}
 
#Private Subnet
resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-private-a"
  }
}

/* gateway */
#Inernet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-IGW"
  }
}

#Nat Gateway
resource "aws_eip" "nat_a" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "private_a" {
  allocation_id                  = aws_eip.nat_a.id
  subnet_id                      = aws_subnet.public_a.id
}

#Route Table
#Public Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-public-rt"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}


resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

#Private Table
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-private-a-rt"
  }
}

resource "aws_route" "private_a" {
  route_table_id = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.private_a.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# Output
output "vpc" {
  value = aws_default_vpc.main.id
}

output "public_a" {
  value = aws_subnet.public_a.id
}

output "private_b" {
  value = aws_subnet.private_a.id
}

output "public_rt" {
  value = aws_route_table.public.id
}

output "private_a_rt" {
  value = aws_route_table.private_a.id
}