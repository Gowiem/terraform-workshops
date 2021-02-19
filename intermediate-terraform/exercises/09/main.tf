terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.0"
}

provider "tls" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.student_alias}_allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "server" {
  key_name   = "${var.student_alias}-key"
  public_key = tls_private_key.server.public_key_openssh
}

resource "aws_instance" "server" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  key_name        = aws_key_pair.server.key_name

  tags = {
    Name = var.student_alias
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.server.private_key_pem
    }
    source      = "./provisioner.sh"
    destination = "/tmp/provisioner.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.server.private_key_pem
    }
    inline = [
      "chmod +x /tmp/provisioner.sh",
      "/tmp/provisioner.sh"
    ]
  }
}
