output "ec2_public_ip" {
  value = aws_instance.default.public_ip
}