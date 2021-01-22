variable "name" {
  default     = "World"
  type        = string
  description = "The name of the individual to say hello to."
}

resource "null_resource" "command" {
  triggers = {
    name = var.name
  }

  provisioner local-exec {
    command = "echo 'Hello ${var.name}!'"
  }
}

output "executed_command" {
  value       = "echo 'Hello ${var.name}!'"
  description = "The command that was executed against the local machine."
}
