# Exercise 7: Diving Deeper into Modules

Maybe you've had the opportunity to use modules in some complex ways already. We're going to try to explore some of that here.

## Local Project Modules as an Organizational Element

As we discussed, one use of modules can simply be to organize within a project, and not be intended to be shared out. Your instructor has used them in this way many times in this way for real projects. So, let's see what that looks like in a somewhat realistic scenario.

Go ahead and switch to the `./project-modules` directory

We're yet again using our remote state approach here just to help it set in, and to hopefully make this your default approach instead of local state. So, let's init our project as we've been before. A few things to note as we do so this time, again replacing `[student-alias]` with your assigned alias:

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
```

Another aside before we move forward with this exercise specifically

We're able to use the `-backend-config` argument as many times as we like, and in multiple contexts. That arg can accept one of two things:
  * a path to a file containing HCL name/values, very much like a tfvars file
  * or an explicit setting of a value. In the case of `-backend-config=bucket=tf-intermediate-[student-alias]` we're providing an explicit value setting along with our `backend.tfvars`

Let's test out some things to understand loading precedence of that arg. We have the following, alternative `backend-invalid.tfvars` file here in this directory, and here's what it looks like:

```
key = "intermediate-terraform/exercise-07/terraform.tfstate"
region = "us-west-1"
encrypt = true
bucket = "totally-invalid-bucket-name-9129083798723472"
```

We've been passing in our bucket value in via the CLI, but let's see if we now use this as the last `-backend-config` argument in our call

first, let's just remove our `.terraform` directory to start from scratch. Another useful, alternative to this would be to use the `-reconfigure` argument to the `terraform init` command

```
$ rm -rf .terraform
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-luke-skywalker -backend-config=./backend-invalid.tfvars
Initializing modules...
- dynamodb in dynamodb
- ec2 in ec2

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Error: Failed to get existing workspaces: S3 bucket does not exist.

The referenced S3 bucket must have been previously created. If the S3 bucket
was created within the last minute, please wait for a minute or two and try
again.

Error: NoSuchBucket: The specified bucket does not exist
	status code: 404, request id: 1683C8734D432E26, host id: js1qgCynndvqEXidODbkFDVoUH7l789icE5n335UIX+NoIo4V8AP+7bOWg3X2INoThxIjrV3/Rc=
```

The takeaway here is that `-backend-config` can be provided multiple times, and that the order that they are given in a CLI command overrides any settings from before. We've provided a configuration with an invalid bucket name as the final one in the list, thus we get an error telling us our state bucket doesn't exist.

Back to our main line of the exercise, let's get back into a valid state

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias] -reconfigure
Initializing modules...

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.70.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.``
```

Speaking of `-reconfigure`, notice that it's going to re-download the providers (and modules).

We're now successfully re-inited, so let's start to look at our project in more detail. First our root project level

#### `variables.tf`

```hcl
variable "student_alias" {
  type        = string
  description = "Your student alias"
}
```

nothing new here, we're just providing an input that is our student alias, and the purpose is to be able to create uniquely-named resources based on it.

### Now, `main.tf`

```
terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.0"
}

module "dynamodb" {
  source        = "./dynamodb"
  unique_prefix = var.student_alias
  table_name    = "project"
  hash_key      = "project_key"
  range_key     = "project_range_key"
  table_items   = [
    {
      hash_key_value  = "hash-key-1",
      range_key_value = "range-key-1"
    },
    {
      hash_key_value  = "hash-key-2",
      range_key_value = "range-key-2"
    }
  ]
}

module "ec2" {
  source        = "./ec2"
  unique_prefix = var.student_alias
  keys          = [
    {
      name = "one",
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    },
    {
      name = "two",
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }
  ]
}
```

Our project, in this case, is little more than calling other modules that will do things for us. We talked about composability. At a project's best, it might just piece together functionality from a number of different modules or sources to create complex infrastructure, as flat as we can make it. The power of re-usability, organization, etc.

We're calling the dynamodb module or section of our project to presumably create all of the dynamodb-related resources. As the root project owner, I probably don't care about the complexities of what lies within this module or directory. Someone else on my team, or maybe even another team might, and we collaboratively maintain this source.

Not knowing much about this module, all I need to do is pass it some values that make sense for the project:

```
module "dynamodb" {
  source        = "./dynamodb"
  unique_prefix = var.student_alias
  table_name    = "project"
  hash_key      = "project_key"
  range_key     = "project_range_key"
  table_items   = [
    {
      hash_key_value  = "hash-key-1",
      range_key_value = "range-key-1"
    },
    {
      hash_key_value  = "hash-key-2",
      range_key_value = "range-key-2"
    }
  ]
}
```

The module maintainers encapsulate the concerns of the interface presented to me

* creating a DynamoDB database table
* setting the needed hash and range keys to what I want them to be
* populating the table with some values

Note that managing records in a database is not often what Terraform should do since that's often runtime data that will change, not infrastructure. Nonetheless, we're using it for demo purposes here.

Let's look at our next module call

```
module "ec2" {
  source        = "./ec2"
  unique_prefix = var.student_alias
  keys          = [
    {
      name = "one",
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    },
    {
      name = "two",
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }
  ]
}
```

This module presumably contains all resources related to the EC2 service area in AWS for our project. We can encapsulate everything there: EC2 instances, AMIs, security groups, key pairs, and so on. Just another way to separate concerns at the source level.

For the sake of this exercise, the interface into that module is just one that allows us to generically specify key pairs to create or manage. We can give the list of them names, and provide the public key to use in the AWS key pair resource.

In many ways, modules are about abstracting the complexities of managing infrastructure resources. I can make it even easier for my teammates to create a piece of infrastructure based on organizational standards, or even based on norms.

Our root project here is very simple and clear about what it intends to manage. So, let's try to actually run a plan against this project and see what we see

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.dynamodb.aws_dynamodb_table.project will be created
  + resource "aws_dynamodb_table" "project" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "project_key"
      + id               = (known after apply)
      + name             = "force_project"
      + range_key        = "project_range_key"
      + read_capacity    = 20
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + write_capacity   = 20

      + attribute {
          + name = "project_key"
          + type = "S"
        }
      + attribute {
          + name = "project_range_key"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }
    }

  # module.dynamodb.aws_dynamodb_table_item.project[0] will be created
  + resource "aws_dynamodb_table_item" "project" {
      + hash_key   = "project_key"
      + id         = (known after apply)
      + item       = jsonencode(
            {
              + project_key       = {
                  + S = "hash-key-value-1"
                }
              + project_range_key = {
                  + S = "range-key-value-1"
                }
            }
        )
      + range_key  = "project_range_key"
      + table_name = "force_project"
    }

  # module.dynamodb.aws_dynamodb_table_item.project[1] will be created
  + resource "aws_dynamodb_table_item" "project" {
      + hash_key   = "project_key"
      + id         = (known after apply)
      + item       = jsonencode(
            {
              + project_key       = {
                  + S = "hash-key-value-2"
                }
              + project_range_key = {
                  + S = "range-key-value-2"
                }
            }
        )
      + range_key  = "project_range_key"
      + table_name = "force_project"
    }

  # module.ec2.aws_key_pair.project[0] will be created
  + resource "aws_key_pair" "project" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = (known after apply)
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }

  # module.ec2.aws_key_pair.project[1] will be created
  + resource "aws_key_pair" "project" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = (known after apply)
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }

Plan: 5 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Some first things to notice with our plan are items like

```
+ name             = "force_project"
+ range_key        = "project_range_key"
```

Our root project is merely passing values through from its own parameters to the modules its using to produced plan values as such.

Notice also that we have plan logs that say things like `# module.dynamodb.aws_dynamodb_table.project will be created` related to modules. These are useful in being able to identify what will potentially create a resource in the modules being included and used in a project. A resource name or namespace is easy to track in this way based on the root project owner's known definitions.

We've done very little within the root of our project to create some reasonably complex infrastructure. The power of modules, and the organization of it all, even if they're not shared modules, is a good model.

### Let's apply this and look at some things

```
$ terraform apply
[... our plan from above ...]
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.ec2.aws_key_pair.project[0]: Creating...
module.ec2.aws_key_pair.project[1]: Creating...
module.dynamodb.aws_dynamodb_table.project: Creating...
module.ec2.aws_key_pair.project[0]: Creation complete after 0s [id=force-one-ecf34f57-3eef-aec1-3cbd-54afe38a0b8f]
module.ec2.aws_key_pair.project[1]: Creation complete after 0s [id=force-two-8972dc37-db52-ba5e-a0a8-eb8ced32e735]
module.dynamodb.aws_dynamodb_table.project: Creation complete after 6s [id=force_project]
module.dynamodb.aws_dynamodb_table_item.project[1]: Creating...
module.dynamodb.aws_dynamodb_table_item.project[0]: Creating...
module.dynamodb.aws_dynamodb_table_item.project[1]: Creation complete after 0s [id=force_project|project_key||hash-key-value-2||project_range_key||range-key-value-2|]
module.dynamodb.aws_dynamodb_table_item.project[0]: Creation complete after 0s [id=force_project|project_key||hash-key-value-1||project_range_key||range-key-value-1|]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

project_keys = [
  {
    "arn" = "arn:aws:ec2:us-west-1:946320133426:key-pair/force-one-ecf34f57-3eef-aec1-3cbd-54afe38a0b8f"
    "fingerprint" = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    "id" = "force-one-ecf34f57-3eef-aec1-3cbd-54afe38a0b8f"
    "key_name" = "force-one-ecf34f57-3eef-aec1-3cbd-54afe38a0b8f"
    "key_pair_id" = "key-05b76c426b033bbef"
    "public_key" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
  },
  {
    "arn" = "arn:aws:ec2:us-west-1:946320133426:key-pair/force-two-8972dc37-db52-ba5e-a0a8-eb8ced32e735"
    "fingerprint" = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    "id" = "force-two-8972dc37-db52-ba5e-a0a8-eb8ced32e735"
    "key_name" = "force-two-8972dc37-db52-ba5e-a0a8-eb8ced32e735"
    "key_pair_id" = "key-00ab0fc7d3ee20186"
    "public_key" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
  },
]
project_table_arn = arn:aws:dynamodb:us-west-1:946320133426:table/force_project
```

We'll focus on a few things here related to the apply and then look at state as well

We've gotten some pretty complex output from our project. We're of course not doing much at the project level, simply telling our modules to do stuff for us and then getting some output from those modules. In the case of the `project_keys` output of our root project level, let's look at what's happening. Here are our output definitions at the root project level

```
output "project_table_arn" {
  value = module.dynamodb.table_arn
}

output "project_keys" {
  value = module.ec2.keys
}
```

This is really nothing more than us passing the module outputs that were given to us directly back out of our project as well. We need only know of the outputs available to us by the modules, and we can output them from our project in turn.

Let's now look at the ec2's module output definition related to `keys` in `ec2/outputs.tf`

```
output "keys" {
  value = aws_key_pair.project
}
```

and then the `aws_key_pair.project` resource definition:

```
resource "aws_key_pair" "project" {
  count      = length(var.keys)
  key_name   = "${var.unique_prefix}-${var.keys[count.index].name}-${uuid()}"
  public_key = var.keys[count.index].public_key
}
```

We're able to just reference that resource as a whole via an output. Which is pretty cool. The key takeaway being that we don't have to reference an attribute of a resource when outputting values, we can just as well reference all attributes from a resource, or even in this case, since we're using `count`, we can reference the list of things the resource is creating for us, each list item containing a key with all its attributes.

I want to take this opportunity to note something else interesting that's going on in this `aws_key_pair.project` resource definition as well: we're using an input variable itself to drive the count and the values set for each key being created. Let's look at the input variable declaration:

```
variable "keys" {
  type = list(object({
    name        = string
    public_key  = string
  }))
}
```

So, it's a list of objects. We've opened up the ability to pretty generically create any number of keys to the user of this module. And here's how we're using it in our root project:

```
keys          = [
  {
    name = "one",
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
  },
  {
    name = "two",
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
  }
]
```

This list is driving a pretty simple resource definition in the module itself. Modules can determine the best user experience for things like this based on what the module itself believes needs to be exposed vs abstracted away from the user. Here's the resource definition in the module:

```
resource "aws_key_pair" "project" {
  count      = length(var.keys)
  key_name   = "${var.unique_prefix}-${var.keys[count.index].name}-${uuid()}"
  public_key = var.keys[count.index].public_key
}
```

Using a built-in terraform function, `length`, we can count the number of `var.keys` passed to our module, and reference the object key/values for each list item via the syntax like `var.keys[count.index].name`

Before we move on, **make sure to run a destroy to pull down the resources we created above**

```
$ terraform destroy
...
```

Let's look at one last thing in this `project-modules` directory. Look at `.terraform/modules/modules.json`

```
{"Modules":[{"Key":"","Source":"","Dir":"."},{"Key":"dynamodb","Source":"./dynamodb","Dir":"dynamodb"},{"Key":"ec2","Source":"./ec2","Dir":"ec2"}]}
```

This is the local project file that tells terraform commands what `init` discovered or pulled as far as modules are concerned. In the case of just having local modules housed within the project, `terraform init` was able to set this file to tell `terraform plan/apply/etc` where it can find and execute modules. Just a pointer to the locations where they exist within our project in this case.

## Making use of third-party modules

OK, now switch to the other directory in this exercise directory

```
$ cd ../third-party-modules
```

And let's first look at our `main.tf` file in this project:

```
terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.0"
}

data "aws_vpc" "default" {
  default = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.13.0"
  name    = "${var.student_alias}-sg"
}

module "dynamodb_table" {
  source    = "github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v0.6.0"
  name      = "${var.student_alias}-table"
  hash_key  = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]
}
```

We're using 2 modules made available to us by the community:

* The security group one is hosted at Terraform Registry, we're locking to version 3.13.0
* The dynamodb table module we'll pull directly from github, and tell Terraform that we want to lock to version v0.6.0 of that module

Let's run a `terraform init` and see what happens:

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
Initializing modules...
Downloading github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v0.6.0 for dynamodb_table...
- dynamodb_table in .terraform/modules/dynamodb_table
Downloading terraform-aws-modules/security-group/aws 3.13.0 for security_group...
- security_group in .terraform/modules/security_group/terraform-aws-security-group-3.13.0

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.70.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We're most interested in the top output. We can see `init` doing its job to go out and get the modules that are referenced in our terraform configuration

```
Initializing modules...
Downloading github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v0.6.0 for dynamodb_table...
- dynamodb_table in .terraform/modules/dynamodb_table
Downloading terraform-aws-modules/security-group/aws 3.13.0 for security_group...
- security_group in .terraform/modules/security_group/terraform-aws-security-group-3.13.0
```

Let's look more closely then at the contents of our `.terraform` directory related to this:

```
$ ls -la .terraform/modules
total 8
drwxr-xr-x   5 gowiem  staff  160 Aug  9 15:42 .
drwxr-xr-x   5 gowiem  staff  160 Aug  9 15:43 ..
drwxr-xr-x  18 gowiem  staff  576 Aug  9 15:42 dynamodb_table
-rw-r--r--   1 gowiem  staff  371 Aug  9 15:42 modules.json
drwxr-xr-x   3 gowiem  staff   96 Aug  9 15:42 security_group
```

Terraform has indeed downloaded the third-party modules here, the directory names matching the identifier that we've assigned to the module call in our code, e.g. `module "security_group"`. Within each directory is the source for the module.

Now, let's look at the contents of our `modules.json`:

```
{"Modules":[{"Key":"","Source":"","Dir":"."},{"Key":"dynamodb_table","Source":"github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v0.6.0","Dir":".terraform/modules/dynamodb_table"},{"Key":"security_group","Source":"terraform-aws-modules/security-group/aws","Version":"3.13.0","Dir":".terraform/modules/security_group/terraform-aws-security-group-3.13.0"}]}
```

Somewhat similar to what we saw with our local, project defined modules, but Terraform is storing some extra data here related to remote source locations. It also is storing info on how further terraform commands can find the locally-downloaded module source, so that `terraform plan/apply/etc` can point to these locations when actually running our terraform configuration.

Let's go ahead and apply our configuration

```
$ terraform apply
Error: Missing required argument

  on main.tf line 13, in module "security_group":
  13: module "security_group" {

The argument "vpc_id" is required, but no definition was found.
```

Ah! There's something wrong with our configuration. So the security group module that we're using has a required variable that we're not setting on the module call we're making from our project:

```
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.13.0"
  name    = "${var.student_alias}-sg"
}
```

If we look at the documentation for this module, we'll notice we have one more required argument to the module, `vpc_id`: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/3.13.0?tab=inputs#required-inputs

So, let's add that. We've already included the data source in our project to query for our default VPC. We need only reference the ID attribute of that data source to add the required argument to our module call:

```
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.13.0"
  name    = "${var.student_alias}-sg"
  vpc_id  = data.aws_vpc.default.id
}
```

The main takeaway here is that a missing variable value at the module level will not prompt, it will fail notifying the user of the missing value.

After making our fix, let's do any apply again

```
$ terraform apply
data.aws_vpc.default: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.dynamodb_table.aws_dynamodb_table.this[0] will be created
  + resource "aws_dynamodb_table" "this" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "id"
      + id               = (known after apply)
      + name             = "force-table"
      + stream_arn       = (known after apply)
      + stream_enabled   = false
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Name" = "force-table"
        }

      + attribute {
          + name = "id"
          + type = "N"
        }

      + point_in_time_recovery {
          + enabled = false
        }

      + server_side_encryption {
          + enabled     = false
          + kms_key_arn = (known after apply)
        }

      + timeouts {
          + create = "10m"
          + delete = "10m"
          + update = "60m"
        }

      + ttl {
          + enabled = false
        }
    }

  # module.security_group.aws_security_group.this_name_prefix[0] will be created
  + resource "aws_security_group" "this_name_prefix" {
      + arn                    = (known after apply)
      + description            = "Security Group managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = (known after apply)
      + name_prefix            = "force-sg-"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "force-sg"
        }
      + vpc_id                 = "vpc-75a4a012"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.security_group.aws_security_group.this_name_prefix[0]: Creating...
module.dynamodb_table.aws_dynamodb_table.this[0]: Creating...
module.security_group.aws_security_group.this_name_prefix[0]: Creation complete after 2s [id=sg-0b762dcc892baceff]
module.dynamodb_table.aws_dynamodb_table.this[0]: Creation complete after 9s [id=force-table]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Success! We've created some infrastructure with pretty minimal project configuration. Using modules available to us, we can keep our project configuration manageable, re-use common-need configuration from elsewhere, and focus our project on the things that make our project unique.

## Finishing up

Let's do a destroy to finish out this exercise

```
$ terraform destroy
...
```
