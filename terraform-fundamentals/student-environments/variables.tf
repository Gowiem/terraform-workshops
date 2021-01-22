variable "pgp_key_filename" {
  default     = "iam_user_key.pub"
  type        = string
  description = "Filename of the base64 encoded gpg key for use in encrypting user passwords."
}
