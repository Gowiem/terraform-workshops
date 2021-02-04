provider "aws" {
  region = "us-east-1"
}

variable "conditional_object_enabled" {
  default     = true
  type        = bool
  description = "Whether or not to create the 'conditional' S3 bucket object"
}

locals {
  key_names = [
    "one",
    "two",
    "three"
  ]
}

resource "aws_s3_bucket" "default" {
  bucket = "count-examples"
}

resource "aws_s3_bucket_object" "objects" {
  count = 3

  bucket  = aws_s3_bucket.default.id
  key     = "object-${local.key_names[count.index]}.txt"
  content = "This is object #${count.index}!"
}

resource "aws_s3_bucket_object" "conditional_object" {
  count = var.conditional_object_enabled ? 1 : 0

  bucket  = aws_s3_bucket.default.id
  key     = "object-conditional.txt"
  content = "This will only be created if `var.conditional_object_enabled` is `true`."
}
