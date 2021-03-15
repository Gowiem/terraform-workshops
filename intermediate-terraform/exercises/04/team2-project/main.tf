terraform {
  backend "s3" {}
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-intermediate-${var.student_alias}-team2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}-team2@masterpoint.io"
}

data "terraform_remote_state" "team1" {
  backend = "s3"
  config = {
    bucket = "tf-intermediate-${var.student_alias}"
    key    = "intermediate-terraform/exercise-04/team1-project/terraform.tfstate"
    region = "us-east-2"
  }
}
