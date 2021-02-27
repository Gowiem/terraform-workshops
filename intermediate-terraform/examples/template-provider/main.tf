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
    instance_name = var.instance_name
    https_enabled = var.https_enabled
  }
}

output "config_content" {
  value       = data.template_file.config.rendered
  description = "The template generated configuration file."
}
