terraform {

  # NOTE: Bucket is required to be passed in to ensure that student bring their own bucket.
  backend "s3" {
    key     = "intermediate-terraform/experiment-01/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
