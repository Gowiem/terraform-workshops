locals {
  generated_password = base64encode(var.string_var)
}
