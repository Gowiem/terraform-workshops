terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.0"
}

data "aws_vpc" "default" {
  default = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.13.0"
  name    = "${var.student_alias}-sg"
}

module "dynamodb_table" {
  source    = "github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v0.6.0"
  name      = "${var.student_alias}-table"
  hash_key  = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]
}
