# Exercise 10: Taints and Destroy Targets

Taints are a good way to force replace a resource. Destroy targets give us a way to remove sinlge pieces of our infrastructure at a time

## Taints

Let's start by creating our infrastructure, which will create 2 distinct key pairs

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
...
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair_01 will be created
  + resource "aws_key_pair" "my_key_pair_01" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker-01"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }

  # aws_key_pair.my_key_pair_02 will be created
  + resource "aws_key_pair" "my_key_pair_02" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker-02"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair_02: Creating...
aws_key_pair.my_key_pair_01: Creating...
aws_key_pair.my_key_pair_01: Creation complete after 0s [id=tf-intermediate-luke-skywalker-01]
aws_key_pair.my_key_pair_02: Creation complete after 0s [id=tf-intermediate-luke-skywalker-02]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

So, we have our two key pairs created. Let's say we wanted to force recreate the second one. We might change a value on the resource that would do so or update it in place, but in certain cases, for certain resources, you simply want to force recreate with the same values in one action. Let's taint the second one and see what happens

```
$ terraform taint aws_key_pair.my_key_pair_02
Resource instance aws_key_pair.my_key_pair_02 has been marked as tainted.
```

Much like `state rm`, `import`, etc. dealing with single resources at a time is all about referencing the resource identifier as written in our configuration. So, I've marked this resource from configuration as tainted. Let's run a plan to see what that output tells us will happen on our next apply

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair_02: Refreshing state... [id=tf-intermediate-luke-skywalker-02]
aws_key_pair.my_key_pair_01: Refreshing state... [id=tf-intermediate-luke-skywalker-01]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair_02 is tainted, so must be replaced
-/+ resource "aws_key_pair" "my_key_pair_02" {
      ~ arn         = "arn:aws:ec2:us-east-2:946320133426:key-pair/tf-intermediate-luke-skywalker-02" -> (known after apply)
      ~ fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62" -> (known after apply)
      ~ id          = "tf-intermediate-luke-skywalker-02" -> (known after apply)
        key_name    = "tf-intermediate-luke-skywalker-02"
      ~ key_pair_id = "key-0db5cb1a1e1cc9046" -> (known after apply)
        public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
      - tags        = {} -> null
    }

Plan: 1 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

We do indeed see that it will be replaced on our next apply with a `-/+` which means the previous resource will be removed, and the new one will be created after it. What if we changed our mind or realized we want the existing one to stick around. We've set ourselves up for the next apply to perform the above operation. We can simply `untaint` though if we need to back out of this:

```
$ terraform untaint aws_key_pair.my_key_pair_02
Resource instance aws_key_pair.my_key_pair_02 has been successfully untainted.
```

And the plan again

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair_01: Refreshing state... [id=tf-intermediate-luke-skywalker-01]
aws_key_pair.my_key_pair_02: Refreshing state... [id=tf-intermediate-luke-skywalker-02]

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

Back to where we were, no changes needed, the resource is going to stick around.

## Destroy Targets

Now, let's look at the case where we just want to fully remove our second key, but we'd like the first one to stay around. Now, you might be saying "why don't we just remove it from configuration source and apply"? And you'd be right to ask this. I've found that this feature isn't so often used for destroying indefinitely, rather when you need to remove/recreate a resource, but the taint model doesn't necessarily work for your needs. Maybe you need to recreate it from scratch, but not just yet. You don't want the configuration to go away from your source, because you will be re-creating. In reality I've used this feature NEVER :) But you should know it's there and how to use it

```
$ terraform destroy -target aws_key_pair.my_key_pair_02
aws_key_pair.my_key_pair_02: Refreshing state... [id=tf-intermediate-luke-skywalker-02]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair_02 will be destroyed
  - resource "aws_key_pair" "my_key_pair_02" {
      - arn         = "arn:aws:ec2:us-east-2:946320133426:key-pair/tf-intermediate-luke-skywalker-02" -> null
      - fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62" -> null
      - id          = "tf-intermediate-luke-skywalker-02" -> null
      - key_name    = "tf-intermediate-luke-skywalker-02" -> null
      - key_pair_id = "key-0db5cb1a1e1cc9046" -> null
      - public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io" -> null
      - tags        = {} -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.


Warning: Resource targeting is in effect

You are creating a plan with the -target option, which means that the result
of this plan may not represent all of the changes requested by the current
configuration.

The -target option is not for routine use, and is provided only for
exceptional situations such as recovering from errors or mistakes, or when
Terraform specifically suggests to use it as part of an error message.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_key_pair.my_key_pair_02: Destroying... [id=tf-intermediate-luke-skywalker-02]
aws_key_pair.my_key_pair_02: Destruction complete after 0s

Warning: Applied changes may be incomplete

The plan was created with the -target option in effect, so some changes
requested in the configuration may have been ignored and the output values may
not be fully updated. Run the following command to verify that no other
changes are pending:
    terraform plan

Note that the -target option is not suitable for routine use, and is provided
only for exceptional situations such as recovering from errors or mistakes, or
when Terraform specifically suggests to use it as part of an error message.


Destroy complete! Resources: 1 destroyed.
```

There's some interesting output here related to `-target` and potentially-incomplete changes. The best thing for us to do is just run a plan again to continue to make sense of it:

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair_01: Refreshing state... [id=tf-intermediate-luke-skywalker-01]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair_02 will be created
  + resource "aws_key_pair" "my_key_pair_02" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker-02"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 di@masterpoint.io"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

our second key remains in configuration, now removed from state and the resource actually deleted from AWS. Important to note that we'd now remove it from configuration as well if we wanted it to go away for good.

## Finish by destroying the rest

```
$ terraform destroy
...
```
