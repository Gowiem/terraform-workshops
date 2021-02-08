## Example of Dynamic Block
#############################
## Full info @ https://www.terraform.io/docs/language/expressions/dynamic-blocks.html

locals {
  account_ids = [
    "123",
    "456",
    "789",
  ]
}

data "aws_iam_policy_document" "admin_assume_role_policy_dynamic" {
  dynamic "statement" {
    for_each = local.account_ids
    content {
      actions = [
        "sts:AssumeRole"
      ]
      resources = [
        "arn:aws:iam::${statement.value}:role/admin"
      ]
    }
  }
}

# The above is the same as this:
data "aws_iam_policy_document" "admin_assume_role_policy_non_dynamic" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::123:role/admin"
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::456:role/admin"
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::789:role/admin"
    ]
  }
}
