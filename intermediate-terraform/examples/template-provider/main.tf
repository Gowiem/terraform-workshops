variable "instance_name" {
  type        = string
  description = "The name of the instance that we're creating a config file for"
}

variable "https_enabled" {
  type        = bool
  description = "Whether or not the configuration defines if HTTPS should be enabled"
}

data "template_file" "config" {
  template = file("${path.root}/config.tpl")
  vars = {
    https_enabled = var.https_enabled
    instance_name = var.instance_name
  }
}

provider "template" {}

locals {
  template_content = data.template_file.config.rendered
}


resource "local_file" "foo" {
  content  = yamlencode(data.template_file.config.rendered)
  filename = "${path.module}/config.yaml"
}
