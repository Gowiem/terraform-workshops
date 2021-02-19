output "string_var" {
  value = var.string_var
}

output "number_var" {
  value = var.number_var
}

output "bool_var" {
  value = var.bool_var
}

output "list_any_var" {
  value = var.list_any_var
}

output "list_number_var" {
  value = var.list_number_var
}

output "map_any_var" {
  value = var.map_any_var
}

output "map_bool_var" {
  value = var.map_bool_var
}

output "set_any_var" {
  value = var.set_any_var
}

output "set_string_var" {
  value = var.set_string_var
}

output "object_person_var" {
  value = var.object_person_var
}

output "tuple_line_item_var" {
  value = var.tuple_line_item_var
}

output "list_object_people_var" {
  value = var.list_object_people_var
}

output "untyped_var" {
  value = var.untyped_var
}

output "generated_password" {
  value = "${local.generated_password}"
  sensitive = true
}
