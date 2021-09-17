# The `sensitive` flag for the `variable` block is only available in 0.14+.
# It has been around longer for the `output` block.
terraform {
  required_version = ">= 0.14.0"
}

variable "api_key" {
  # sensitive   = true
  type        = string
  description = "A sensitive value"
}

resource "null_resource" "print_sensitive_value" {
  triggers = {
    "api_key" = var.api_key
  }

  provisioner "local-exec" {
    command = "echo ${var.api_key}"
  }
}

output "api_key" {
  value       = var.api_key
  # sensitive   = true
  description = "A sensitive value"
}
