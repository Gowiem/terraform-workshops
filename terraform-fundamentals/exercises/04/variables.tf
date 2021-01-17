# variables.tf

# Declare a variable so we can use it.
variable "student_alias" {
  description = "Your student alias"
}

# The following configuration is used to grab a generated s3 bucket name from a separate terraform project under the
# "other_project" folder.  tfstate files are provided for you for simplicity.

data "terraform_remote_state" "other_project" {
  backend = "local"
  config = {
    path = "other_project/terraform.tfstate"
  }
}

output "other_project_bucket" {
  value = "${data.terraform_remote_state.other_project.outputs.bucket_name}"
}