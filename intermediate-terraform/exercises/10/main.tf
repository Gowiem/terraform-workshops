terraform {
  backend "s3" {}
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_ecr_repository" "student_repo" {
  name                 = "${var.student_alias}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}