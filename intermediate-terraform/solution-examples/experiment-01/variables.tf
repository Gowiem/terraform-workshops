variable "region" {
  type        = string
  description = "The region that all AWS resources are deployed to."
}

variable "student_alias" {
  type        = string
  description = "The student's alias that will help create unique resources"
}
