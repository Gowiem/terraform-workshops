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

module "security_group" {
  source                = "./security-group"
  name                  = "${var.student_alias}-experiment-01"
  allowed_inbound_ports = [80, 22]
  allow_outbound        = true
  env                   = terraform.workspace
}

data "template_file" "server_user_data" {
  template = file("user-data.sh.tmpl")
  vars = {
    service_name = "nginx"
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  user_data = data.template_file.server_user_data.rendered

  security_groups = [module.security_group.info.name]

  tags = {
    Name = "${var.student_alias}-experiment-01"
    Env  = terraform.workspace
  }
}
