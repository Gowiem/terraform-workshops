terraform {
  required_providers {
    aws = "~> 2.0"
  }
}

resource "aws_security_group" "server" {
  name        = var.name

  dynamic "ingress" {
    iterator = port
    for_each = var.allowed_inbound_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    iterator = port
    for_each = var.allow_outbound ? ["enable"] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Env = var.env
  }
}
