# main.tf

# Declare the provider being used, in this case it's AWS.
# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {}

# declare a resource block so we can create something.
resource "aws_s3_bucket" "student_bucket_alt" {
  bucket = "tf-fundy-${var.student_alias}-alt"
}

