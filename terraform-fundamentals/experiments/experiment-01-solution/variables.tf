variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The region in AWS where we'll be deploying our resources to."
}

variable "student_alias" {
  type        = string
  description = "The alias of the student to help with naming."
}
