# root terraform configuration, no interpolation supported in this block
# we're saying here that all the following code requires at least terraform version 0.12.26 or greater
terraform {
  required_version = ">= 0.12.26"

  required_providers {
    # this version constraint says that we need to use the most recent 3.x version of the provider
    aws = {
      # In versions 0.13+, you must specify the source of the provider.
      # This will cause an error in 0.12 however, so we leave it commented out.
      # source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# see the options and configuration for the AWS provider at: https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

locals {
  vpc_id_tag = "default-${data.aws_vpc.default.id}"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-intermediate-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}@masterpoint.io"
  tags = {
    in_vpc = local.vpc_id_tag
  }
}

resource "aws_eip" "my_eip" {
  vpc = true
  tags = {
    in_vpc = local.vpc_id_tag
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  name    = var.student_alias
  vpc_id  = data.aws_vpc.default.id
}
