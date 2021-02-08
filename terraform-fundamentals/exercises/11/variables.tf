variable "aws_region" {
  description = "The region where resources should live"
}

variable "student_alias" {
  description = "Your student alias"
}

variable "key_name" {
  default     = ""
  description = <<-EOT
  The name of the EC2 Key Pair that can be used to SSH to the EC2 Instances.
  Leave blank to not associate a Key Pair with the Instances."
  EOT
}

variable "frontend_server_text" {
  default     = "Hello from frontend"
  description = "The text the frontend should return for HTTP requests"
}

variable "backend_server_text" {
  default     = "Hello from backend"
  description = "The text the backend should return for HTTP requests"
}
