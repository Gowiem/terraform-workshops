output "nginx_server_ip" {
  value = aws_instance.nginx_server.public_ip
}

