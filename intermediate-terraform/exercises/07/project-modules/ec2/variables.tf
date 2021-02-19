variable "unique_prefix" {
  type = string
}

variable "keys" {
  type = list(object({
    name        = string
    public_key  = string
  }))
}
