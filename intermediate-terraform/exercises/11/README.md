# Exercise 10: Terraform Refresh

We're going to create a piece of infrastructure, go make some changes to it via the AWS console, and then see what happens when we refresh state on our project

## First, create the infrastructure

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
...
$ terraform apply
...
```

This is the exact same project configuration content as our previous exercise, just a single key pair in our us-east-2 region.

Let's inspect the state for our project

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 0,
  "lineage": "36271482-c2e2-8fe6-7113-03b06b4bc96a",
  "outputs": {},
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
            "arn": "arn:aws:ec2:us-east-2:946320133426:key-pair/tf-intermediate-luke-skywalker",
            "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
            "id": "tf-intermediate-luke-skywalker",
            "key_name": "tf-intermediate-luke-skywalker",
            "key_name_prefix": null,
            "key_pair_id": "key-0e34cea4e66ac802f",
            "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io",
            "tags": null
          },
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    }
  ]
}
```

Note especially `"tags": null`. We're going to go add some tags to our key via the console, so we can see how Terraform is able to pick up those changes and pull them into state with a refresh.

Navigate in the AWS console to key pairs in the us-east-2 region, and locate the one for your student alias. If you need help finding your way, just let your instructor know. Once you've found your key, select the checkbox on that line, then click on the "Actions" dropdown in the top right. Select "Manage Tags" from there. Add a few tags, whatever you like. When you're done, you can navigate back to your Cloud9 environment console so we can run the refresh

```
$ terraform refresh
aws_key_pair.my_key_pair: Refreshing state... [id=tf-intermediate-luke-skywalker]
```

Great, so let's see what that did to our state:

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 1,
  "lineage": "36271482-c2e2-8fe6-7113-03b06b4bc96a",
  "outputs": {},
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
            "arn": "arn:aws:ec2:us-east-2:946320133426:key-pair/tf-intermediate-luke-skywalker",
            "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
            "id": "tf-intermediate-luke-skywalker",
            "key_name": "tf-intermediate-luke-skywalker",
            "key_name_prefix": null,
            "key_pair_id": "key-0e34cea4e66ac802f",
            "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io",
            "tags": {
              "CreatedBy": "force",
              "Purpose": "Exercise11"
            }
          },
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    }
  ]
}
```

Our project state is now aware of the tags added manually outside of Terraform. Now, what if we ran a plan now, though? Let's see that

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair: Refreshing state... [id=tf-intermediate-luke-skywalker]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be updated in-place
  ~ resource "aws_key_pair" "my_key_pair" {
        arn         = "arn:aws:ec2:us-east-2:946320133426:key-pair/tf-intermediate-luke-skywalker"
        fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
        id          = "tf-intermediate-luke-skywalker"
        key_name    = "tf-intermediate-luke-skywalker"
        key_pair_id = "key-0e34cea4e66ac802f"
        public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
      ~ tags        = {
          - "CreatedBy" = "Gowiem" -> null
          - "Purpose"   = "Exercise11" -> null
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Ah, so our configuration doesn't include these new tags yet though, so Terraform is resolving our state against our configuration, and it sees these tags as "removed" from our configuration at this stage. Similar to import, we have to address some things in most cases where refresh is useful. Namely, let's start managing these tags in our actual configuration. Change your key pair resource in `main.tf` to be:

```
resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-intermediate-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}@masterpoint.io"
  tags = {
    [whatever tags you set]
  }
}
```

and then run an plan again

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair: Refreshing state... [id=tf-intermediate-luke-skywalker]

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

State and project configuration are now in sync!

## Finish off by destroying

```
$ terraform destroy
...
```
