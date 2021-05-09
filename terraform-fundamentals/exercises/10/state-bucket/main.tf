provider "aws" {}

variable "student_alias" {
  description = "Your student alias"
}

# We can see this separate project that's just in charge of setting up our state bucket
# One might also just do this manually
resource "aws_s3_bucket" "state_bucket" {
  bucket_prefix = "tf-fundys-${var.student_alias}-"
  force_destroy = true
}

output "state_bucket_name" {
  value = aws_s3_bucket.state_bucket.bucket
}
