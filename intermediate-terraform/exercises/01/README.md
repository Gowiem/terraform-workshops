# Exercise #1: Refresh w/ a Project Exercise

We want this exercise to be a refresher on some key topics, and adding just a few new concepts or twists as we jump back into a path toward intermediate knowledge

Some intro topics refreshed in this exercise:

* input variables, tfvars
* providers, and the AWS provider specifically
* use of modules
* use of data sources
* local variables
* outputs
* the root `terraform` block

## Let's jump right in

Go ahead run `terraform init` in this project directory:

```
$ terraform init
Initializing modules...
Downloading terraform-aws-modules/security-group/aws 3.18.0 for security_group...
- security_group in .terraform/modules/security_group

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 3.31.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Let's look at the individual pieces of this output to re-familiarize ourselves with some pieces of `terraform init`

```
Initializing modules...
Downloading terraform-aws-modules/security-group/aws 3.18.0 for security_group...
- security_group in .terraform/modules/security_group
```

One of `terraform init`'s jobs is to identify modules defined in configuration source and pull them in to the `.terraform/` directory so they can be used when running further `terraform` commands. Here we see `init` identifying a third-party module defined in source and pulling it appropriately. Here's what the module call/definition looks like in our source:

```
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"
  name    = var.student_alias
  vpc_id  = data.aws_vpc.default.id
}
```

This is a pretty standard module block, using a [Terraform Registry](https://registry.terraform.io) provided module. So, one that Hashicorp hosts in its official community registry of modules. Our `init` command has pulled this module from that registry locally to our machine so that we can use it. Notice also, that we've set an explicit version for the module to use, so we can lock to using only this version whenever we run Terraform against this configuration. NOTE: the `version` argument for `module` is only relevant to module whose `source` is Terraform Registry or Terraform Cloud.

Let's look at where and how our `init` command downloaded the module:

```
$ ls -lah .terraform/modules/
total 8
drwxr-xr-x  4 gowiem  staff   128B Aug  7 07:45 .
drwxr-xr-x  4 gowiem  staff   128B Aug  7 07:45 ..
-rw-r--r--  1 gowiem  staff   220B Aug  7 07:45 modules.json
drwxr-xr-x  3 gowiem  staff    96B Aug  7 07:45 security_group
```

We see the module itself downloaded to the `security_group` directory, so there's Terraform source code in there that will actually be used when we run our configuration. `modules.json` is just a metadata file to track Terraform's awareness of pulled modules and such.

OK, on to the next part of the `init` output

```
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.70.0...
```

Initializing the backend: we'll refresh more on later, but in short, this is Terraform preparing for interaction with remote state.

Along with identifying and downloading modules, `init` also identifies providers defined in source and downloads the provider plugins. Remember that providers are key to Terraform. They're the things to define a bulk of the actual functionality when using Terraform, and are supported via a plugin architecture. For example, I want to create and manage resources in AWS, so I make use of the AWS provider which encapsulates all of the functionality to have Terraform interact with the AWS APIs to run these creation and management operations. If we look at our Terraform source for the provider definition:

```
terraform {
  ...

  required_providers {
    # this version constraint says that we need to use the most recent 3.x version of the provider
    aws = {
      # In versions 0.13+, you must specify the source of the provider.
      # This will cause an error in 0.12 however, so we leave it commented out.
      # source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# see the options and configuration for the AWS provider at: https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
  region = var.region
}
```

`terraform init` sees this provider block defined and knows that it needs to go get the AWS provider. It utilizes the `required_providers` block to determine the version constraint if it's not already available locally. `Downloading plugin for provider "aws" (hashicorp/aws) 3.31.0...` from the logs indicates that it found the version it needs and is downloading it. This provider, or plugin is also pulled into the `.terraform` directory:

```
$ ls -la .terraform/plugins/linux_amd64/
total 371144
drwxr-xr-x  4 gowiem  staff        128 Aug  7 07:45 .
drwxr-xr-x  3 gowiem  staff         96 Aug  7 07:45 ..
-rwxr-xr-x  1 gowiem  staff         79 Aug  7 07:45 lock.json
-rwxr-xr-x  1 gowiem  staff  189435008 Aug  7 07:45 terraform-provider-aws_v3.31.0_x5
```

A provider or plugin is nothing more than a compiled binary that Terraform calls in the execution of terraform commands. This provider binary for AWS is now available locally so that Terraform can make use of it for creating and managing AWS-related resources and other AWS related operations built-in to the provider.

Now, if we run `terraform init` again we'll see the following:

```
$ terraform init
Initializing modules...

Initializing the backend...

Initializing provider plugins...

...
```

This time around `terraform init` didn't install our module to provider, which is because the `init` command is idempotent. We've already downloaded the versions of modules and provider plugins needed, so Terraform is able to determine that and not attempt a download again. If you wanted to force re-download modules and plugins, you could use the `-upgrade=true` arg for the `init` command

```
$ terraform init -upgrade=true
Upgrading modules...
Downloading terraform-aws-modules/security-group/aws 3.18.0 for security_group...
- security_group in .terraform/modules/security_group

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 3.31.0...

...
```

### The root `terraform` block

OK, let's go start to actually look at our configuration source. You'll notice in `main.tf` there's a root `terraform` block defined like:

```
# root terraform configuration, no interpolation supported in this block
# we're saying here that all the following code requires at least terraform version 0.12.26 or greater
terraform {
  required_version = ">= 0.12.26"

  required_providers {
    # this version constraint says that we need to use the most recent 3.x version of the provider
    aws = {
      # In versions 0.13+, you must specify the source of the provider.
      # This will cause an error in 0.12 however, so we leave it commented out.
      # source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

This simply gives us a way to ensure that no terraform commands can be run against this configuration unless the version of the `terraform` CLI being used is at least version `0.12.26`. You'll also notice we're specifying the version of our AWS provider in this block which is new in `0.12.26` and above. The root terraform block is also where you configure remote backend settings, which we'll get back to soon, as well as a few other things like experimental feature enablement.

### A look at the rest of the source

We have some additional files here in source:

* `variables.tf`: where we define terraform input variable declarations, so the parameters that can be passed in to our project
* `terraform.tfvars`: one of the ways in which we can pass in those variable values or parameters
* `outputs.tf`: where we define terraform project outputs, so dynamic values to be passed back out of the project
* `main.tf`: our main file containing resource and data source definitions

Let's look at the rest of `main.tf`

```
data "aws_vpc" "default" {
  default = true
}

locals {
  vpc_id_tag = "default-${data.aws_vpc.default.id}"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-intermediate-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}@masterpoint.io"
  tags = {
    in_vpc = local.vpc_id_tag
  }
}

resource "aws_eip" "my_eip" {
  vpc = true
  tags = {
    in_vpc = local.vpc_id_tag
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.13.0"
  name = var.student_alias
  vpc_id = data.aws_vpc.default.id
}

```

our first block is a data source, and one that's going to query the AWS API by way of the AWS provider that our `init` command downloaded. We're using a provider-defined data source called `aws_vpc`. We want to query to get info about a VPC that _already exists_ in our AWS account. In this case the default VPC for the region as configured in our AWS provider block.

We can then reference the VPC's ID in other places. And we see that happen as we're setting a local variable:

```
locals {
  vpc_id_tag = "default-vpc-${data.aws_vpc.default.id}"
}
```

We're using string interpolation to set a local variable called `vpc_id_tag` that contains the value of our default VPC id. Remember locals are values that can be re-used within your configuration, but aren't passed in. We're setting up this local to use it in a few other places within our config: setting tags on multiple other resources

The final 3 blocks in this file represent resources we want to create and manage via Terraform in our AWS infrastructure:

* an AWS key pair
* an AWS elastic IP
* an AWS security group via a community module being used to create the resource

Let's run a `terraform plan` now and look through the output:

```
$ terraform plan
var.region
  the region where resources will be created

  Enter a value: us-east-2

var.student_alias
  Your student alias

  Enter a value: luke-skywalker

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_vpc.default: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.my_eip will be created
  + resource "aws_eip" "my_eip" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "in_vpc" = "default-vpc-6342f808"
        }
      + vpc                  = true
    }

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
      + tags        = {
          + "in_vpc" = "default-vpc-6342f808"
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
      + name_prefix            = "luke-skywalker-"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "luke-skywalker"
        }
      + vpc_id                 = "vpc-6342f808"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

You've been prompted for values to the defined input variables in the `variables.tf` file:

```
# we keep variables in a separate file simply as a matter of best-practice
# under-the-hood Terraform will merge all files together, and doesn't really care whether
# HCL is in one file or many

variable "region" {
  description = "the region where resources will be created"
}

variable "student_alias" {
  description = "Your student alias"
}

```

We have no defaults defined for these variables, thus Terraform needs values for them, so it's prompting us. Something we can do to prevent being prompted is to put values in our `terraform.tfvars` file. Open that file and edit with the following info, replacing `[student-alias]` with your assigned student alias:

```
# fill in your variables accordingly here
student_alias="[student-alias]"
region="us-east-2"
```

And run `terraform plan` again. You should not be prompted. Terraform will read input values from the `terraform.tfvars` file to get the values it needs. Do you remember all the other ways you can pass in variable values in automated ways?

Finally, let's take a look at our `outputs.tf` file:

```
output "eip_public_ip" {
  value = aws_eip.my_eip.public_ip
}
```

Outputs are useful pieces of data to come out of a particular Terraform project. In this case, we're referencing a value that was filled in upon creating our AWS elastic IP resource. AWS internally created that resource and assigned a public IP to it. We can reference that output (refered to as an "attribute") of the resource, and pass it out of our project as well. This particular example might be useful if you have other processes or other projects after this one that needs this IP to, say, update DNS records.

That's it for this refresher exercise. We won't actually apply any of this configuration.
