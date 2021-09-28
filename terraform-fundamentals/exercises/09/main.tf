# main.tf

# Declare the provider being used, in this case it's AWS.
# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {}

# declare a resource block so we can create something.
resource "aws_s3_bucket_object" "dynamic_file" {
  count   = var.object_count
  bucket  = "tf-fundys-${var.student_alias}"
  key     = "dynamic-file-${count.index}"
  content = "dynamic-file at index ${count.index}"
}

resource "aws_s3_bucket_object" "optional_file" {
  count   = var.include_optional_file ? 1 : 0
  bucket  = "tf-fundys-${var.student_alias}"
  key     = "optional-file"
  content = "optional-file"
}

