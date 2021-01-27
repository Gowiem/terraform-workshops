locals {
  example = "argument"
}

data "aws_s3_bucket" "example_bucket" {
  # ...
}

resource "aws_instance" "example" {
  ami = "abc123"

  network_interface {
    # This is a nested block
  }
}

module "rds_cluster" {
  # ...
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

provider "github" {
  # ...
}
