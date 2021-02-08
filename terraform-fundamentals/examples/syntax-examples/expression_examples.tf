# The below is a fairly exhaustive showcase of the many types of
# Terraform expressions. This example is only assigning the expressions
# to `locals` as an example -- you can assign the below expressions to any
# argument in a block however (some exceptions e.g. `provider` block).
# This example is not runnable, but is expected to be used as a reminder / reference.
# For full documentation on expressions see:
# https://www.terraform.io/docs/language/expressions/index.html

## Literals
############

locals {
  string_exp  = "Hello World."
  boolean_exp = true
  number_exp  = 47
  array_exp   = ["Hey!", "Ho!", "Let's Go!"]
  map_exp     = { "key1" = "value1", "key2" = "value2" }
}

## References
##############

locals {
  resource_ref = aws_s3_bucket.function_storage.id
  data_ref     = data.aws_vpc.target_vpc.arn
  modules_ref  = module.database.username
}

## Values from Complex Types + locals + variables
##################################################

locals {
  list_ref   = local.array_exp[2]
  map_ref    = local.map_exp["key2"]
  object_ref = var.person.name
}

## Path + Terraform Meta Information
#####################################

locals {
  current_working_directory = path.cwd
  module_directory          = path.module
  root_module_directory     = path.root

  terraform_workspace = terraform.workspace
}

## Build-in Functions
######################

locals {
  max_exp        = max(5, 12, 9) # 12
  format_exp     = format("Hello, %s!", var.name)
  split_exp      = split(",", "foo,bar,baz") # [ "foo", "bar", "baz" ]
  coalesce_exp   = coalesce("a", "b")        # a
  coalesce_exp_2 = coalesce("", "b")         # b

  # Dozens of others -- see full reference @
  # https://www.terraform.io/docs/language/functions/index.html
}

## Conditionals
################

locals {
  foo_count = var.foo_enabled ? 1 : 0
}

## String Interpolation
########################

locals {
  group                = "Class"
  string_interpolation = "Afternoon, ${local.group}!" # Afternoon, Class!
}

## HEREDOC Syntax
##################

locals {
  heredoc = <<EOT
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur.
EOT

  # Prefer to us indented > normal i.e. use the `-`
  indented_heredoc = <<-EOT
  Lorem ipsum dolor sit amet, consectetur adipiscing elit,
  sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
  nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
  reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
  pariatur.
  EOT

  # Note that EOT can be any uppercase string (e.g. CONFIG_FILE)
  config_file_content = <<-CONFIG_FILE
  [profile finn]
  output=json
  region=us-west-2
  credential_process=aws-vault exec finn --json
  CONFIG_FILE
}

## String Template Directives
##############################

locals {
  directive = <<-EOT
  %{for ip in aws_instance.example.*.private_ip}
  server ${ip}
  %{endfor}
  EOT
}

## Splat Syntax
################

locals {
  array_of_maps = [{ "key" = "value1" }, { "key" = "value2" }, { "key" = "value3" }]
  splat         = local.array_of_maps[*].key # [ "value1", "value2", "value3" ]
}

## For Syntax
##############

locals {
  list       = ["Hey!", "Ho!", "Let's Go!"]
  uppercased = [for i in local.list : upper(i)]

  conditional = [
    for i in local.list :
    upper(i)
    if i != "Hey!"
  ]

  users_arr = [
    { name = "matt_gowie", role = "teacher" },
    { name = "luke_skywalker", role = "student" },
  ]

  # Loop over the array of users to convert it to a map where the key is the
  # name of the user and the value is the user's attributes
  # e.g. { "matt_gowie" = { name = "matt_gowie", role = "teacher" }, ...  }
  users = { for repo in local.users_arr : repo.name => repo }
}

## Combinations
################

locals {
  combo_1 = 1 + 10 + max(5, 12, 9) # 23
  combo_2 = var.foo_enabled ? "${upper(var.foo)} was enabled" : "Bar was enabled && ${local.combo_1}"
  combo_3 = contains(concat([md5("hello ${lower(var.foo)}"), "hello bar"], ["hello baz"]), "hello baz") # true
  combo_4 = <<-EOT
  %{for ip in aws_instance.example.*.private_ip}
  server ${coalesce(ip, var.default_private_ip)}
  %{endfor}
  EOT
}
