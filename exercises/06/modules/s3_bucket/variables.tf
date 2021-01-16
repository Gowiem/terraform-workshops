# variables.tf

# Declare a variable so we can use it.
variable "region" {
  default = "us-west-2"
}

variable "student_alias" {
  description = "Your student alias"
}