# we keep variables in a separate file simply as a matter of best-practice
# under-the-hood Terraform will merge all files together, and doesn't really care whether
# HCL is in one file or many

variable "region" {
  description = "the region where resources will be created"
}

variable "student_alias" {
  description = "Your student alias"
}
