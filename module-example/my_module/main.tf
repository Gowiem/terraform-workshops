variable "thing" {
  type = string
}

resource null_resource "null" {
  provisioner local-exec { 
    command = "echo ${var.thing}"
  }
}
