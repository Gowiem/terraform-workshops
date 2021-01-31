# We've already seen this one...

# A resource block with 2 labels
resource "aws_instance" "example" {
  ami = "ami-1098230490283" # an argument

  # This is a nested block with no labels
  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }
}

# NOTE: We'll see these later in the course...
###############################################
locals {
  example = "argument"
}

data "aws_s3_bucket" "example_bucket" {
  # ...
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
