resource "aws_instance" "bastion" {
  instance_type = "t3.small"
  subnet_id = aws_subnet.public_a.id
  associate_public_ip_address = true
  private_ip = "10.0.2.30"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name = aws_key_pair.keypair.key_name
}