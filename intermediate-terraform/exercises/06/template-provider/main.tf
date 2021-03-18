variable "network_on" {
  type    = bool
  default = false
}

variable "enable_security" {
  type      = bool
  default   = true
}

provider "template" {}

data "template_file" "config" {
  template = file("template.tmpl")
  vars = {
    network_on       = var.network_on
    enable_security  = var.enable_security
  }
}

output "template_rendered" {
  value = data.template_file.config.rendered
}
