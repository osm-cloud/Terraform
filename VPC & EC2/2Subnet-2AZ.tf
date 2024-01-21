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
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "<env>-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "100.10.3.0/24"
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
    Name = "<env>-rt"
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
    Name = "<env>-a-rt"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "<env>-b-rt"
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

/* Security Group */
resource "aws_security_group" "bastion" {
  name = "<env>-ec2-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }
}

#IAM
resource "aws_iam_role" "bastion" {
  name = "<env>-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "<env>-profile-ec2"
  role = aws_iam_role.bastion.name
}

#EC2
#key_pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "keypair" {
  key_name = "<env>"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "keypair" {
  content = tls_private_key.rsa.private_key_pem
  filename = "./<env>.pem"
}

  #Instance
    #Public
resource "aws_instance" "bastion" {
  instance_type = "<type>"
  subnet_id = aws_subnet.public_a.id
  associate_public_ip_address = true
  private_ip = "10.0.2.30"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name = aws_key_pair.keypair.key_name
  
  ami = "ami-04ab8d3a67dfe6398"

  tags = {
    Name = "<env>-bastion"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y jq curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ln -s /usr/local/bin/aws /usr/bin/
    ln -s /usr/local/bin/aws_completer /usr/bin/
  EOF
}