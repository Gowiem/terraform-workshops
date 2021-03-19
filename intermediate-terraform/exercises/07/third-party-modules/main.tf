terraform {
  backend "s3" {}
}

provider "aws" {}

data "aws_vpc" "default" {
  default = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.13.0"
  name    = "${var.student_alias}-sg"
}

module "dynamodb_table" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=tags/0.22.0"

  namespace = "mp"
  name      = "${var.student_alias}-dynamo-table"

  hash_key          = "HashKey"
  range_key         = "RangeKey"
  enable_autoscaler = false

  dynamodb_attributes = [
    {
      name = "DailyAverage"
      type = "N"
    },
    {
      name = "HighWater"
      type = "N"
    },
    {
      name = "Timestamp"
      type = "S"
    }
  ]
}
