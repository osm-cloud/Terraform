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
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-b"
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

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-private-b"
  }
}

resource "aws_subnet" "protected_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-protected-a"
  }
}

resource "aws_subnet" "protected_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-protected-b"
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

resource "aws_eip" "nat_b" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "private_a" {
  allocation_id                  = aws_eip.nat_a.id
  subnet_id                      = aws_subnet.public_a.id
}

resource "aws_nat_gateway" "private_b" {
  allocation_id                  = aws_eip.nat_b.id
  subnet_id                      = aws_subnet.public_b.id
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

resource "aws_route_table_association" "public_b" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

#Private Table
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-private-a-rt"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-private-b-rt"
  }
}

resource "aws_route" "private_a" {
  route_table_id = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.private_a.id
}

resource "aws_route" "private_b" {
  route_table_id = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.private_b.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

# Protected Table
resource "aws_route_table" "protected_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-protected-a-rt"
  }
}

resource "aws_route_table" "protected_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-protected-b-rt"
  }
}

# Output
output "vpc" {
  value = aws_vpc.main.id
}

output "public_a" {
  value = aws_subnet.public_a.id
}

output "public_b" {
  value = aws_subnet.public_b.id
}

output "private_a" {
  value = aws_subnet.private_a.id
}

output "private_b" {
  value = aws_subnet.private_b.id
}

output "public_rt" {
  value = aws_route_table.public.id
}

output "private_a_rt" {
  value = aws_route_table.private_a.id
}

output "private_b_rt" {
  value = aws_route_table.private_b.id
}