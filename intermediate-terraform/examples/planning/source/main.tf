terraform {
  backend "s3" {
    bucket = "rockholla-di-force"
    key    = "intermediate-terraform/examples-planning/terraform.tfstate"
    region = "us-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.0"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = "examples-planning"
  }
}
