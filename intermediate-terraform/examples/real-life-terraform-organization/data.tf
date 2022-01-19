data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${module.this.id}-vpc"]
  }
}
