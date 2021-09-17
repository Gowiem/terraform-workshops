provider "aws" {
  region = "us-east-1"
}

module "nuke_bomber" {
  source = "../../../../masterpoint/terraform-aws-nuke-bomber"
  # source  = "masterpointio/nuke-bomber/aws"
  # version = "0.2.0"

  namespace   = "mp"
  environment = "ue1"
  stage       = "teaching"
  name        = "nuke-bomber"

  # Run every Sunday at 5am UTC
  schedule_expression = "cron(0 5 ? * SUN *)"

  command = ["-c", "/home/aws-nuke/nuke-config.yml", "--force", "--force-sleep", "3", "--no-dry-run"]
}