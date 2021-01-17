variable "aws_region" {
  description = "The region where resources should live"
}

variable "student_alias" {
  description = "Your student alias"
}

variable "key_name" {
  description = "The name of the EC2 Key Pair that can be used to SSH to the EC2 Instances. Leave blank to not associate a Key Pair with the Instances."
  default     = ""
}

variable "frontend_server_text" {
  description = "The text the frontend should return for HTTP requests"
  default     = "Hello from frontend"
}

variable "backend_server_text" {
  description = "The text the backend should return for HTTP requests"
  default     = "Hello from backend"
}
