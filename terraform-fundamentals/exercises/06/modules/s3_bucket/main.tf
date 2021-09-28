# main.tf

# Declare the provider being used, in this case it's AWS.
# This provider supports setting the provider version, AWS credentials as well as the region.
# It can also pull credentials and the region to use from environment variables, which we have set, so we'll use those
provider "aws" {
  region = var.region
}

# declare a resource block so we can create something.
resource "aws_s3_bucket" "user_bucket_random" {
  # bucket_prefix is a nice option in the aws provider for creating s3 buckets
  # the suffix will be a semi-random sequence
  bucket_prefix = "tf-fundys-${var.student_alias}-"
}
