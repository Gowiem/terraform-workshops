variable "student_alias" {
  type = string
}

locals {
  env = {
    dev = {
      region = "us-east-2"
    }
    prod = {
      region = "us-east-2"
    }
  }
}
