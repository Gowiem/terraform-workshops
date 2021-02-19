variable "name" {
  type = string
}

variable "allowed_inbound_ports" {
  type = list(number)
}

variable "allow_outbound" {
  type = bool
}

variable "env" {
  type = string
}
