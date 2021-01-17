variable "my_string" {
  type    = string
  default = "my_string_value"
}

variable "my_number" {
  type    = number
  default = 10
}

variable "my_bool" {
  type    = bool
  default = true
}

output "my_string_interpolated" {
  value = "${var.my_string}_interpolated"
}

output "my_number_plus_two" {
  value = "${var.my_number + 2}"
}

output "my_bool_negated" {
  value = "${!var.my_bool}"
}

output "my_bool_value" {
  value = "${var.my_bool == true ? "my_bool is true" : "my_bool is false"}"
}