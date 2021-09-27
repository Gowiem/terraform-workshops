locals {
  all_accounts = {
    management = {
      name  = "mp-management"
      email = "contact+management@masterpoint.io"
      tags = {
        env       = "management"
        owner     = "MG"
        namespace = "mp"
      }
    }

    dev = {
      name  = "mp-dev"
      email = "contact+dev@masterpoint.io"
      tags = {
        env       = "dev"
        owner     = "MG"
        namespace = "mp"
      }
    }

    stage = {
      name  = "mp-stage"
      email = "contact+stage@masterpoint.io"
      tags = {
        env       = "stage"
        owner     = "MG"
        namespace = "mp"
      }
    }

    prod = {
      name  = "mp-prod"
      email = "contact+prod@masterpoint.io"
      tags = {
        env       = "prod"
        owner     = "MG"
        namespace = "mp"
      }
    }
  }
}

resource "aws_organizations_account" "account" {
  for_each = local.all_accounts

  name  = each.value.name # "mp-${each.key}" # mp-dev, mp-stage, etc.
  email = each.value.email
  tags  = each.value.tags
}
