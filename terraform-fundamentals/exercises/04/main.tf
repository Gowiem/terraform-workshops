# main.tf

# Declare the provider being used, in this case it's AWS.
# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {}

# declare a resource block so we can create something.
resource "aws_s3_bucket_object" "user_student_alias_object" {
  bucket  = "tf-fundys-${var.student_alias}"
  key     = "student.alias"
  content = "This bucket is reserved for ${var.student_alias}"
}

# The following configuration is used to grab a generated s3 bucket name from a separate terraform project under the
# "other_project" folder.  tfstate files are provided for you for simplicity.
data "terraform_remote_state" "other_project" {
  backend = "local"
  config = {
    path = "other_project/terraform.tfstate"
  }
}
