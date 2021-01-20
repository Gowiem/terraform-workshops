variable "pgp_key_filename" {
  default     = "iam_user_key.pub"
  type        = string
  description = "Filename of the base64 encoded gpg key for use in encrypting user passwords."
}

variable "link_to_slides" {
  type        = string
  description = "The link to the course slide deck that will be emailed to all students."
}

variable "link_to_survery" {
  type        = string
  description = "The link to the feedback survey that will be emailed to all students."
}
