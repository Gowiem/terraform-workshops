variable "student_alias" {
  type = string
}

locals {
  env = {
    dev = {
      region = "us-west-1"
    }
    prod = {
      region = "us-east-2"
    }
  }
}
