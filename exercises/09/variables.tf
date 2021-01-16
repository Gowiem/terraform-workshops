# variables.tf

# Declare a variable so we can use it.
variable "student_alias" {
  description = "Your student alias"
}

variable "object_count" {
  type        = number
  description = "number of dynamic objects/files to create in the bucket"
  default     = 3
}

variable "include_optional_file" {
  type        = bool
  default     = true
}