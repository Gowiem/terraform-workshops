variable "pgp_key_filename" {
  default     = "iam_user_key.pub"
  type        = string
  description = "Filename of the base64 encoded gpg key for use in encrypting user passwords."
}

variable "email_enabled" {
  default     = false
  type        = bool
  description = <<-EOT
  Whether or not to send the course instructions via email or not.
  If not enabled then the course instructions are written to disk for each student in the `messages/` folder."
  EOT
}
