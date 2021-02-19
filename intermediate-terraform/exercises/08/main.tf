provider "aws" {
  version = "~> 2.0"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_invalid_resource_type" "name" {
  id = "${var.student_alias}-01"
}
