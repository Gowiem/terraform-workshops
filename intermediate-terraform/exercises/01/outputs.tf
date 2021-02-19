output "eip_public_ip" {
  value = "${aws_eip.my_eip.public_ip}"
}
