# Exercise 5: Workspaces

Workspaces are simple but powerful. This exercise will demonstrate both.

## The basics of workspaces

```
$ terraform workspace --help
Usage: terraform workspace

  new, list, show, select and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
```

Even without knowing you're using a workspace, you always are in terraform. One named default:

```
$ terraform workspace show
default
$ terraform workspace list
* default

```

The asterisk in the `workspace list` above denotes the current workspace.

Let's start by looking at our project structure, first `variables.tf`

```
variable "student_alias" {
  description = "Your student alias"
}
```

Nothing new here really, just a way for us to pass in our student alias to create a uniquely-named resource. Looking at `main.tf`

```
provider "aws" {
  version = "~> 2.0"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-intermediate-${var.student_alias}-${terraform.workspace}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}@masterpoint.io"
  tags = {
    env = "${terraform.workspace}"
  }
}
```

Mostly familiar here, too, except we're referencing something new, a built-in variable to terraform: `terraform.workspace`. Which will give us the name of the current workspace, thus we can have differently suffixed key names for each environment.

Good, but wait, we could change workspace to be "dev" vs "prod", etc. but in the normal flow of a single project, changing that value will simply create or alter a single key pair with the new name. Enter workspaces so we can maintain separate state files per environment:

```
$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
$ terraform workspace list
  default
* dev
```

We've made a new workspace, terraform automatically switches to it by default. This will be our dev environment workspace. Notice a few things in your local project directory:

* `.terraform/environment` stores the workspace name currently being used
* `terraform.tfstate.d` will store the isolated, separate state files for each workspace, and you'll see `terraform.tfstate.d/dev` to confirm this

Note that the above works just the same for remote state. We're using the default local state here just to see things more easily for the first time. In the case of remote state `terraform.tfstate.d` simply ends up in the remove backend storage.

Let's go ahead and init

```
$ terraform init
...
```

A normal init operation, no different really in the context of isolated workspaces since modules used, providers/plugins used, etc. will be common across all workspaces at the source level and will go into our `.terraform` directory.

```
$ terraform plan
var.student_alias
  Your student alias

  Enter a value: luke-skywalker

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker-dev"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
      + tags        = {
          + "env" = "dev"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

We can see that our key pair name is set as we expect it to be with the `-dev` sufix, and the related tag set as expected. Let's apply and actually create our key pair for the dev environment

```
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: luke-skywalker


An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker-dev"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
      + tags        = {
          + "env" = "dev"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions in workspace "dev"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair: Creating...
aws_key_pair.my_key_pair: Creation complete after 1s [id=tf-intermediate-luke-skywalker-dev]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Our key pair is created for our dev environment. Let's quickly note that we have an isolated state file now stored in our `terraform.tfstate.d` directory for dev:

```
$ ls -la terraform.tfstate.d/dev/
total 8
drwxr-xr-x  3 gowiem  staff    96 Aug  7 17:39 .
drwxr-xr-x  3 gowiem  staff    96 Aug  7 17:38 ..
-rw-r--r--  1 gowiem  staff  1311 Aug  7 17:39 terraform.tfstate
```

Note that this `terraform.tfstate.d` directory would be stored in our remote backend if we were using a remote state backend. For the sake of being able to work with and see this for potentially the first time, we're using local state.

Time to switch workspaces and test some further things out. Let's switch to a new `prod` workspace

```
$ terraform workspace new prod
terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

We've created and switched to this new workspace, so we should simply be able to run another apply to create entirely new infrastructure from scratch with a brand new state file, and a non-conflicting key pair name in AWS since it's name/identifer will be suffixed with our unique workspace name:


```
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: luke-skywalker


An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker-prod"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
      + tags        = {
          + "env" = "prod"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions in workspace "prod"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair: Creating...
aws_key_pair.my_key_pair: Creation complete after 0s [id=tf-intermediate-luke-skywalker-prod]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

A brand new key pair was created `tf-intermediate-luke-skywalker-prod`

And we have a totally different state file managed for this run/workspace:

```
$ ls -la terraform.tfstate.d/prod/
total 8
drwxr-xr-x  3 gowiem  staff    96 Aug  7 17:50 .
drwxr-xr-x  4 gowiem  staff   128 Aug  7 17:42 ..
-rw-r--r--  1 gowiem  staff  1315 Aug  7 17:50 terraform.tfstate
```

Know that the term "workspace" is a bit overloaded when it comes to terraform CLI local operations vs the capabilities of Terraform Cloud/Enterprise. Both use much of the same functionality, but some additional things can be confusing when workspaces in Terraform Cloud are discussed, such as isolated execution environments.

One last thing to clarify: your workspace selection is only persisted in a Terraform project directory. So, moving between projects means you'll simply be using the workspace that was last being used in a project directory.

# Finishing up

We want to clean up the resources we've created here:

```
$ terraform destroy
...
$ terraform workspace select dev
$ terraform destroy
...
```
