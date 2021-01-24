output "instance_id" {
  value       = aws_instance.web.id
  description = "The ID of the EC2 instance that we create."
}
