locals {
  example = "argument"
}

resource "aws_instance" "example" {
  ami = "abc123"

  network_interface {
    # ...
  }
}

variable "ami" {
  description = "The Amazon Machine Image to use."
}

output "instance_id" {
  value       = aws_instance.example.id
  description = "The ID of the created EC2 instance."
}

terraform {
  # ...
}
