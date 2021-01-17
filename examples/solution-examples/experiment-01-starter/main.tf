provider "aws" {
  # fill in
}

data "aws_ami" "ubuntu" {
  # Find the most recent Ubuntu image, as we did in the notes
}

resource "aws_security_group" "nginx" {
  name        = "nginx_firewall"
  description = "Firewall for the nginx-server"

  # you'll need to set up the allowed traffic in and out
}

resource "aws_instance" "nginx_server" {
  # You'll need to finsh the arguments for this resource.
  # Make sure you provide all required arguments.
  # User_data will let you provide a script to run on the instance.
}
