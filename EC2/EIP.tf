#EIP
resource "aws_eip" "ec2" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
}