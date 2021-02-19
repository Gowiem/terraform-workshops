# Primitives
variable "string_var" {
  type = string
}

variable "number_var" {
  type = number
}

variable "bool_var" {
  type = bool
}

# Complex: Collection
variable "list_any_var" {
  type = list(any)
}

variable "list_number_var" {
  type = list(number)
}

variable "map_any_var" {
  type = map(any)
}

variable "map_bool_var" {
  type = map(bool)
}

variable "set_any_var" {
  type = set(any)
}

variable "set_string_var" {
  type = set(string)
}

# Complex: Structural
variable "object_person_var" {
  type = object({
    name = string,
    age = number
  })
}

variable "tuple_line_item_var" {
  type = tuple([
    string,
    number,
    bool
  ])
}

# Complex: Embedded
variable "list_object_people_var" {
  type = list(object({
    name = string,
    age = number
  }))
}

# Untyped
variable "untyped_var" {}
