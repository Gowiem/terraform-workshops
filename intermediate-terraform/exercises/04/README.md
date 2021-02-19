# Exercise 4: Intermediate State Management and Operations

We've gotten a lot of chances to work with and understand state along the way. We'll continue to dive in deeper as we move along. State, being one if not the most important aspects of Terraform, warrants continual study.

Let's start by reviewing and using one of the more important operations around state: Planning

## Terraform Plans and Applies

Plans along with state are the foundational way that Terraform resolves what is currently running in your infrastrucure, vs what should be. The declarative model in practice. Let's use this exercise to create some infrastructure in two different, distinct projects. We'll work our way through state awareness, state management, planning, and even cross-project state awareness.

Go ahead and change directories into the `team1-project` one here. And we'll run the following, as before replacing `[student-alias]` with the one assigned to you:

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=rockholla-di-[student-alias]
...
$ terraform show

$ terraform plan
var.student_alias
  Your student alias

  Enter a value: force

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
      + key_name    = "rockholla-di-force"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

A few things to note at this stage:

* We're continuing to use a remote state here, just like we did in exercise 2
* We used the `terraform show` command to inspect our state as the step just after init. Clearly no state will be created or available since this is a new project, and we see that in the empty output from the command. It's telling us that our state is empty currently.
* `terraform plan` shows us that our current configuration source in comparison to the empty state tells us and terraform alike that we need to create our `aws_key_pair` resource. It's represented in the plan output clearly.
* We always have a summary at the end of our plan telling us what needs to be created, changed, or removed: `Plan: 1 to add, 0 to change, 0 to destroy.`

```
Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Our final bit of plan output echos the idea we covered that specifying a plan file as output for plan is recommended

Let's go ahead and apply this configuration. Notice that the apply command naturally includes a plan as the step so we can see the changes to be made just before actually running the apply:

```
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: force


An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair: Creating...
aws_key_pair.my_key_pair: Creation complete after 0s [id=rockholla-di-force]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

my_key_pair_id = key-0f87362ef96c0d8b3
```

Excellent, so we've created our actual first resource of the course by way of an apply. We were asked to approve the plan. If we didn't to be prompted we could've used the `-auto-approve` argument to apply. That argument is there to support automated workflows, which we'll cover more on that tomorrow and the other various arguments and settings that Terraform supports for such workflows like continuous integration pipelines and even what Hashicorp itself has implemented with Terraform Cloud and Enterprise.

On apply, Terraform also gives us a nice log of what happened, so the process and steps as it's creating our resources. Similar to plan, it gives us a summary of all that did happen: `Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`

OK, that's most refresher material though. Let's get into some newer and more intermediate level content.

### Looking at our project state

The easiest way to get a look at the current state of your project is to use the `terraform show` command

```
$ terraform show
# aws_key_pair.my_key_pair:
resource "aws_key_pair" "my_key_pair" {
    arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force"
    fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    id          = "rockholla-di-force"
    key_name    = "rockholla-di-force"
    key_pair_id = "key-0f87362ef96c0d8b3"
    public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org"
    tags        = {}
}


Outputs:

my_key_pair_id = "key-0f87362ef96c0d8b3"
```

We can also get the json version of the state using a similar command

```
$ terraform show -json
{"format_version":"0.1","terraform_version":"0.12.29","values":{"outputs":{"my_key_pair_id":{"sensitive":false,"value":"key-0f87362ef96c0d8b3"}},"root_module":{"resources":[{"address":"aws_key_pair.my_key_pair","mode":"managed","type":"aws_key_pair","name":"my_key_pair","provider_name":"aws","schema_version":1,"values":{"arn":"arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force","fingerprint":"d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62","id":"rockholla-di-force","key_name":"rockholla-di-force","key_name_prefix":null,"key_pair_id":"key-0f87362ef96c0d8b3","public_key":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org","tags":{}}}]}}}
```

This format obviously designed for machine-readable scenarios, so automated processes that might need access to a given project's current state. A similar option is to use `terraform state pull`

```
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 4,
  "lineage": "90214d12-071f-ca0e-db78-36c82c69d94c",
  "outputs": {
    "my_key_pair_id": {
      "value": "key-0f87362ef96c0d8b3",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_key_pair",
      "name": "my_key_pair",
      "provider": "provider.aws",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "arn": "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force",
            "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
            "id": "rockholla-di-force",
            "key_name": "rockholla-di-force",
            "key_name_prefix": null,
            "key_pair_id": "key-0f87362ef96c0d8b3",
            "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org",
            "tags": {}
          },
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    }
  ]
}
```

This `state pull` command simply gets the state file as-is, either local or remote, and outputs it to stdout.

One last thing to call out as we look at raw state here: notice that the state has more data about our `aws_key_pair` than we defined in our configuration. Our configuration specifies the explicit values we need or want to set on our resource. Terraform and the AWS provider makes a request to the API to create, update, etc. the resource, and the API responds back with the AWS-populated values for the resource. For example, we see the `"key_pair_id": "key-0f87362ef96c0d8b3"` value in state. This value of the resource was generated by AWS when creating the resource then communicated by to Terraform so it can fill in the value in the state.

### Making some changes, re-planning, and using the plan -out argument

Let's add another resource to our configuration. Update the `main.tf` file here, adding the following resource at the end:

```
resource "aws_eip" "my_eip" {
  vpc = true
}
```

Then run

```
$ terraform plan -out=plan.out
var.student_alias
  Your student alias

  Enter a value: force

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.my_eip will be created
  + resource "aws_eip" "my_eip" {
      + allocation_id     = (known after apply)
      + association_id    = (known after apply)
      + customer_owned_ip = (known after apply)
      + domain            = (known after apply)
      + id                = (known after apply)
      + instance          = (known after apply)
      + network_interface = (known after apply)
      + private_dns       = (known after apply)
      + private_ip        = (known after apply)
      + public_dns        = (known after apply)
      + public_ip         = (known after apply)
      + public_ipv4_pool  = (known after apply)
      + vpc               = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: plan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.out"
```

Our existing key pair resource is created and up-to-date, so terraform is able to resolve what's in the state file/what's actually in AWS with what's in our config to determine that no changes are needed to that resource.

Per our addition to our source, it also detected this additional resource it needs to create, and we're being informed of this on our plan. There's `1 to add` and we can see the details of the `aws_eip` to add.

Last, we see that our inclusion of `-out=plan.out` gives us some additional instruction at the end:

```
This plan was saved to: plan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.out"
```

Before we actually apply this plan file, let's actually inspect it:

```
$ terraform show plan.out
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_eip.my_eip will be created
  + resource "aws_eip" "my_eip" {
      + allocation_id     = (known after apply)
      + association_id    = (known after apply)
      + customer_owned_ip = (known after apply)
      + domain            = (known after apply)
      + id                = (known after apply)
      + instance          = (known after apply)
      + network_interface = (known after apply)
      + private_dns       = (known after apply)
      + private_ip        = (known after apply)
      + public_dns        = (known after apply)
      + public_ip         = (known after apply)
      + public_ipv4_pool  = (known after apply)
      + vpc               = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

The plan file output is a binary, terraform can parse it to show us what it will be instructed to do internally if we apply it. Again, the benefit of a plan file is we can ensure that `terraform apply` will attempt the operations in this plan file, and only these operations. If a plan file is detected as out-of-date, then it will force you to generate a new one.

Let's apply it

```
$ terraform apply plan.out
aws_eip.my_eip: Creating...
aws_eip.my_eip: Creation complete after 1s [id=eipalloc-0cf7da010d5f77406]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

my_key_pair_id = key-0f87362ef96c0d8b3
```

You might notice one thing during this operation: it doesn't prompt for variables. The plan file itself also stores the values we passed during the `terraform plan` operation and simply uses those when applying the plan file.

OK, let's remove this `aws_eip` from our configuration now and track what happens with another plan/apply. Remove this from your `main.tf`

```
resource "aws_eip" "my_eip" {
  vpc = true
}
```

```
$ terraform plan -out=plan.out
var.student_alias
  Your student alias

  Enter a value: force

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force]
aws_eip.my_eip: Refreshing state... [id=eipalloc-0cf7da010d5f77406]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_eip.my_eip will be destroyed
  - resource "aws_eip" "my_eip" {
      - domain           = "vpc" -> null
      - id               = "eipalloc-0cf7da010d5f77406" -> null
      - public_dns       = "ec2-54-241-104-119.us-west-1.compute.amazonaws.com" -> null
      - public_ip        = "54.241.104.119" -> null
      - public_ipv4_pool = "amazon" -> null
      - tags             = {} -> null
      - vpc              = true -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

This plan was saved to: plan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.out"
```

Stepping back out, just like we saw one to add, now we see `1 to destroy`. The power of declarative configuration really shines in this example. Many other infrastructure as code tools don't support the idea of simply removing some piece of code to remove that thing it's managing. In such cases, the code can grow unmanageable quickly and contain stuff related to just ensuring infrastructure is gone. In terraform you simply remove code to remove resources. A powerful model.

Let's apply the plan file yet again

```
$ terraform apply plan.out
aws_eip.my_eip: Destroying... [id=eipalloc-0cf7da010d5f77406]
aws_eip.my_eip: Destruction complete after 1s

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.

Outputs:

my_key_pair_id = key-0f87362ef96c0d8b3
```

Let's go ahead and move over to our other project in this exercise, we'll explore some of the concepts of cross-project state awareness, manual managing state, and the remaining pieces of this exercise:

```
$ cd ../team2-project
```

### Cross-project state awareness

Now we're in a different project, one for "team2" and separate from "team1." We want to see how we can have visibility into the team1 project and its state though. This of course would require that team1's state file is in an s3 bucket location we can read as the AWS account user executing our team2 project. In our case, it's in the same bucket, and we do indeed have privileges to read team1's state file in there.

We'll go ahead and go straight to apply commands for this project

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=rockholla-di-[student-alias]
...
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: force

data.terraform_remote_state.team1: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force-team2"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-team2@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair: Creating...
aws_key_pair.my_key_pair: Creation complete after 1s [id=rockholla-di-force-team2]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

team1_key_pair_id = key-0f87362ef96c0d8b3
```

We're doing 2 things primarily in this project:

* Creating our own key pair for team2
* querying for team1's key pair ID by querying the state of that project in s3 and then providing that value as an output for this project.

Let's look more closely at the second one. Here's the configuration using the `terraform_remote_state` data source type to query team1's state. From `main.tf`:

```
data "terraform_remote_state" "team1" {
  backend = "s3"
  config = {
    bucket = "rockholla-di-${var.student_alias}"
    key    = "intermediate-terraform/exercise-04/team1-project/terraform.tfstate"
    region = "us-west-1"
  }
}
```

When we applied our team1 project, it created its state file in your student bucket at `intermediate-terraform/exercise-04/team1-project/terraform.tfstate`. It also defined an output, like the following (feel free to look back in the team1-project to find):

```
output "my_key_pair_id" {
  value = "${aws_key_pair.my_key_pair.key_pair_id}"
}
```

So, that output can be queried from another project via the `terraform_remote_state` data source. The data source itself storing the outputs of the other project's state in a property called `outputs`. Notice the last part of our apply for this team2 project:

```
Outputs:

team1_key_pair_id = key-0f87362ef96c0d8b3
```

This output is defined as the following within our team2 project:

```
output "team1_key_pair_id" {
  value = data.terraform_remote_state.team1.outputs.my_key_pair_id
}
```

So, accessing the output from that other project via the data source, then outputting that value in this team2 project.

### Manual state management operations

For the last part of this exercise, we're going to explore some state commands that help in moving state around:

* `terraform state rm`
* `terraform state mv`

Let's start by adding another key pair resource to our team2 project. Add the following to the end of your team2-project `main.tf`

```
resource "aws_key_pair" "my_key_pair_additional" {
  key_name   = "rockholla-di-${var.student_alias}-team2-additional"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}+di-team2-additional@rockholla.org"
}
```

and then we'll run an apply

```
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: force

data.terraform_remote_state.team1: Refreshing state...
aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force-team2]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair_additional will be created
  + resource "aws_key_pair" "my_key_pair_additional" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force-team2-additional"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-team2-additional@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair_additional: Creating...
aws_key_pair.my_key_pair_additional: Creation complete after 0s [id=rockholla-di-force-team2-additional]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

team1_key_pair_id = key-0f87362ef96c0d8b3
```

Our additional key pair is created, let's take a look at our state now:

```
$ terraform show
# aws_key_pair.my_key_pair:
resource "aws_key_pair" "my_key_pair" {
    arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-forcelocal.-team2"
    fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    id          = "rockholla-di-forcelocal.-team2"
    key_name    = "rockholla-di-forcelocal.-team2"
    key_pair_id = "key-015002b746a781283"
    public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 forcelocal.+di-team2@rockholla.org"
    tags        = {}
}

# aws_key_pair.my_key_pair_additional:
resource "aws_key_pair" "my_key_pair_additional" {
    arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-forcelocal.-team2-additional"
    fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    id          = "rockholla-di-forcelocal.-team2-additional"
    key_name    = "rockholla-di-forcelocal.-team2-additional"
    key_pair_id = "key-0bce1ae4427e804b5"
    public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 forcelocal.+di-team2-additional@rockholla.org"
}

# data.terraform_remote_state.team1:
data "terraform_remote_state" "team1" {
    backend   = "s3"
    config    = {
        bucket = "rockholla-di-forcelocal."
        key    = "intermediate-terraform/exercise-04/team1-project/terraform.tfstate"
        region = "us-west-1"
    }
    outputs   = {
        my_key_pair_id = "key-0f87362ef96c0d8b3"
    }
    workspace = "default"
}


Outputs:

team1_key_pair_id = "key-0f87362ef96c0d8b3"
```

Let's say a team member was asked to remove the additional key pair from infrastructure, but they're really new and didn't understand that they were supposed to do it via Terraform. So, the key pair is gone in AWS, but still in our state. There are a few different ways we could address such a scenario, and one is to use `terraform state rm [resource]` to just remove all awareness of it from our state. So, let's try that:

```
$ terraform state rm aws_key_pair.my_key_pair_additional
```

and let's do another `terraform show` to verify it's removed:

```
$ terraform show
# aws_key_pair.my_key_pair:
resource "aws_key_pair" "my_key_pair" {
    arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force-team2"
    fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    id          = "rockholla-di-force-team2"
    key_name    = "rockholla-di-force-team2"
    key_pair_id = "key-015002b746a781283"
    public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-team2@rockholla.org"
    tags        = {}
}

# data.terraform_remote_state.team1:
data "terraform_remote_state" "team1" {
    backend   = "s3"
    config    = {
        bucket = "rockholla-di-force"
        key    = "intermediate-terraform/exercise-04/team1-project/terraform.tfstate"
        region = "us-west-1"
    }
    outputs   = {
        my_key_pair_id = "key-0f87362ef96c0d8b3"
    }
    workspace = "default"
}


Outputs:

team1_key_pair_id = "key-0f87362ef96c0d8b3"
```

It is indeed removed from state. It's still in our configuration though, so we'd want to remove it from the configuration as well and we'd be good to go.

In reality though, our current situation in this exercise is that the key pair is still there in AWS. What would happen if we simply tried another apply? So, the configuration for the resource still in our configuration, no awareness in state of the actual resource in AWS though it's still there:

```
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: force

data.terraform_remote_state.team1: Refreshing state...
aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force-team2]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair_additional will be created
  + resource "aws_key_pair" "my_key_pair_additional" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force-team2-additional"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-team2-additional@rockholla.org"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair_additional: Creating...

Error: Error import KeyPair: InvalidKeyPair.Duplicate: The keypair 'rockholla-di-force-team2-additional' already exists.
	status code: 400, request id: 2ef6492c-88df-447b-b7a4-ecb0ae52fa13

  on main.tf line 23, in resource "aws_key_pair" "my_key_pair_additional":
  23: resource "aws_key_pair" "my_key_pair_additional" {
```

There's already a key pair out there with this name, so AWS can't proceed with creating the conflicting resource. Since terraform thought it was a new resource, since its state no longer had any awareness of the resource, the disconnect means that we HAVE to delete it manually now in AWS. Don't worry about doing so, it'll be cleaned up later after the course.

Whether or not the above situation creates an error and conflict or just a duplicate resource depends on the resource type itself. In certain cases, your old resource would just be abandoned and you'd create another non-conflicting resource in its place if things like the name aren't unique.

Go ahead and remove the following from your `main.tf`:

```
resource "aws_key_pair" "my_key_pair_additional" {
  key_name   = "rockholla-di-${var.student_alias}-team2-additional"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}+di-team2-additional@rockholla.org"
}
```

The last command we'll look at in this exercise is `terraform state mv`. The most common use-case that I've encountered for this command is standarizing naming and conventions in terraform configuration. Say you have something like this in your legacy terraform config:

```
resource "aws_instance" "team1-instance" {
  ...
}
```

and maybe your team has decided that all identifiers should be underscore-separated instead of dash-separated. So, you updated your terraform configuration to be:

```
resource "aws_instance" "team1_instance" {
  ...
}
```

But, your state sees this resource (`aws_instance.team1_instance`) as something different, and your previous resource (`aws_instance.team1-instance`) as removed. So, it's going to create the new one from scratch and get rid of the old one. Obviously something we might not want for a server that shouldn't be brought down. But, after renaming the resource in configuration, we can modify the state so that both spots have the new identifer and terraform will see this as no change on the next plan/apply.

Let's give it a try. Rename your `aws_key_pair` in `main.tf` to the following:

```
resource "aws_key_pair" "new_key_pair_name" {
  key_name   = "rockholla-di-${var.student_alias}-team2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}+di-team2@rockholla.org"
}
```

Now, let's go ahead and run a plan to verify that we'll see the old resource get destroyed and the new one created

```
$ terraform plan
var.student_alias
  Your student alias

  Enter a value: force

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.terraform_remote_state.team1: Refreshing state...
aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force-team2]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be destroyed
  - resource "aws_key_pair" "my_key_pair" {
      - arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force-team2" -> null
      - fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62" -> null
      - id          = "rockholla-di-force-team2" -> null
      - key_name    = "rockholla-di-force-team2" -> null
      - key_pair_id = "key-015002b746a781283" -> null
      - public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-team2@rockholla.org" -> null
      - tags        = {} -> null
    }

  # aws_key_pair.new_key_pair_name will be created
  + resource "aws_key_pair" "new_key_pair_name" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "rockholla-di-force-team2"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di-team2@rockholla.org"
    }

Plan: 1 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Indeed we do. This isn't what we want, so let's fix our state file to be aware of the new name:

```
$ terraform state mv aws_key_pair.my_key_pair aws_key_pair.new_key_pair_name
Move "aws_key_pair.my_key_pair" to "aws_key_pair.new_key_pair_name"
Successfully moved 1 object(s).
```

and now, let's try the plan again to ensure that we're all resolved

```
$ terraform plan
var.student_alias
  Your student alias

  Enter a value: force
ß
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.terraform_remote_state.team1: Refreshing state...
aws_key_pair.new_key_pair_name: Refreshing state... [id=rockholla-di-force-team2]

---------------------------------------ß---------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

# Finishing up

Please do the following to clean up after finishing this exercise:

```
$ terraform destroy
...
$ cd ../team1-project
$ terraform destroy
...
```

That's that, and wraps it up for this deep dive session into intermediate to advanced topics on state, planning, and applying.
