variable "name" {
  type        = string
  description = "The name of the security group resource"
}

variable "allowed_inbound_ports" {
  type        = list(number)
  description = "A list of the ports where the security group should allow inbound communication"
}

variable "allow_outbound" {
  type        = bool
  description = "Whether or not to allow resources using the security group to communicate with the external world"
}

variable "env" {
  type        = string
  description = "Which environment that this resource is being deployed for. i.e. dev, stage, prod, etc."
}
