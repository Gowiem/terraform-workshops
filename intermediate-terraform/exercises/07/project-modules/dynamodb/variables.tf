variable "unique_prefix" {
  type = string
}

variable "table_name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type = string
}

variable "table_items" {
  type = list(object({
    hash_key_value  = string
    range_key_value = string
  }))
}
