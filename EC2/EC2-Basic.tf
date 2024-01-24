# EC2
## EC2 Instance
resource "aws_instance" "bastion" {
  instance_type = "<Type>"
  subnet_id = aws_subnet.public_a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name = aws_key_pair.keypair.key_name 
  ami = data.aws_ssm_parameter.latest_ami.value

  
  tags = {
    Name = "wsi-bastion-ec2"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    ...
  EOF
}

## Security Group
resource "aws_security_group" "bastion" {
  name = "<env>-EC2-SG"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "<Port>"
    to_port = "<Port>"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "Port>"
    to_port = "Port>"
  }
}

## IAM
resource "aws_iam_role" "bastion" {
  name = "wsi-bastion-ec2-role"
  
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
  name = "wsi-profile-bastion"
  role = aws_iam_role.bastion.name
}

## key_pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "keypair" {
  key_name = "test"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "keypair" {
  content = tls_private_key.rsa.private_key_pem
  filename = "./test.pem"
}

## AMI
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-x86_64"
}