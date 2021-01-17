variable "my_list" {
  type      = list(string)
  default   = ["1", "2", "3"]
}

variable "my_set" {
  type      = set(number)
  default   = [1, 2, 3, 4, 5]
}

variable "my_tuple" {
  type      = tuple([string, number, string])
  default   = ["1", 2, "3"]
}

variable "my_map" {
  type      = map
  default   = {names: ["John", "Susy", "Harold"], ages: [12, 14, 10]}
}

# How is this different than the map above?
variable "my_object" {
  type      = object({names: list(string), ages: list(number)})
  default   = {names: ["John", "Susy", "Harold"], ages: [12, 14, 10]}
}

output "my_list_index_2" {
  value = "${var.my_list[2]}"
}

output "my_list_values" {
  value = "${var.my_list}"
}

output "my_set_values" {
  value = "${var.my_set}"
}

output "my_tuple_values" {
  value = var.my_tuple
}

output "my_map_values" {
  value = var.my_map # the ability to do this without quotes is new in 0.12!
}

output "my_object_values" {
  value = var.my_object
}