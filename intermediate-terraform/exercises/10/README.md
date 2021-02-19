# Exercise 10: Terraform Import

Remember when we used `terraform state rm` yesterday to essentially abandon a resource from Terraform's control? We're going to do the same thing here so we can import the disconnected infrastructure

## Create our infrastructure item to abandon

Let's init and do an apply to create the single key pair resource defined in this project

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=rockholla-di-[student-alias]
...
$ terraform apply

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
```

Alright, so we now have a key pair created up on AWS. We want to abandon it from our Terraform state so that we can see `terraform import` in action

First, though, let's figure out the key pair ID by looking at our current state

```
$ terraform show
# aws_key_pair.my_key_pair:
resource "aws_key_pair" "my_key_pair" {
    arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force"
    fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62"
    id          = "rockholla-di-force"
    key_name    = "rockholla-di-force"
    key_pair_id = "key-006446b088b64a629"
    public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org"
```

Noting the `id` attribute value here, as we'll need it for our import. We'll go ahead and abandon it from our state.

```
$ terraform state rm aws_key_pair.my_key_pair
Removed aws_key_pair.my_key_pair
Successfully removed 1 resource instance(s).
```

And now let's have a look at our current state:

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 1,
  "lineage": "bd7ae852-5916-7269-4d2e-6eb4d19808ae",
  "outputs": {},
  "resources": []
}
```

Cool, the resource still exists out there, but the state for our project doesn't know about it. Let's get it back into state with an import.

Let's take a moment to look at the help for the import command at this stage:

```
$ terrform import --help
Usage: terraform import [options] ADDR ID

  Import existing infrastructure into your Terraform state.

  This will find and import the specified resource into your Terraform
  state, allowing existing infrastructure to come under Terraform
  management without having to be initially created by Terraform.

  The ADDR specified is the address to import the resource to. Please
  see the documentation online for resource addresses. The ID is a
  resource-specific ID to identify that resource being imported. Please
  reference the documentation for the resource type you're importing to
  determine the ID syntax to use. It typically matches directly to the ID
  that the provider uses.

  The current implementation of Terraform import can only import resources
  into the state. It does not generate configuration. A future version of
  Terraform will also generate configuration.

  Because of this, prior to running terraform import it is necessary to write
  a resource configuration block for the resource manually, to which the
  imported object will be attached.

  This command will not modify your infrastructure, but it will make
  network requests to inspect parts of your infrastructure relevant to
  the resource being imported.
...
```

The `ADDR` mentioned in the usage output is the local terraform configuration `[RESOURCE TYPE].[RESOURCE IDENTIFIER]`. Let's go modify our configuration at this point to make some things clearer. Make our resource block in `main.tf` look like the following, so removing arguments from it

```
resource "aws_key_pair" "my_key_pair" {}
```

So, we have a resource defined, a placeholder for some real piece of infrastructure we want to import, a key pair that exists in AWS

Now, the `ID` part noted in the usage of the help. What this is very much depends on the type of resource. For an EC2 instance, it'll be the instance ID as defined by AWS, in our case for a key pair, it'll be the resource `id` we noted in our terraform show above. So, let's try the import as we should have everything we need to do so.

```
$ terraform import aws_key_pair.my_key_pair rockholla-di-force
aws_key_pair.my_key_pair: Importing from ID "rockholla-di-force"...
aws_key_pair.my_key_pair: Import prepared!
  Prepared aws_key_pair for import
aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

Excellent, so it's seemingly now imported and part of our project state yet again. Let's verify that

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 4,
  "lineage": "bd7ae852-5916-7269-4d2e-6eb4d19808ae",
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
            "arn": "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force",
            "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
            "id": "rockholla-di-force",
            "key_name": "rockholla-di-force",
            "key_name_prefix": null,
            "key_pair_id": "key-006446b088b64a629",
            "public_key": null,
            "tags": {}
          },
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    }
  ]
}
```

Nice, but we have an empty block in our configuration. What would happen if I ran an apply now without filling things back out appropriately in the resource definition block?

```
$ terraform plan

Error: Missing required argument

  on main.tf line 9, in resource "aws_key_pair" "my_key_pair":
   9: resource "aws_key_pair" "my_key_pair" {}

The argument "public_key" is required, but no definition was found.
```

OK, yeah we're missing a required argument in the resource itself. We have to fill this back in. In practice, this is usually just done after an import by looking at the state and setting the configuration values appropriately. Hashicorp notes that at some point in the future Terraform will be able to fill in and modify configuration after an import as well. For now, though, it's on us to do so. Let's get values back in:

```
resource "aws_key_pair" "my_key_pair" {
  key_name   = "rockholla-di-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}+di@rockholla.org"
}
```

And we'll try a terraform plan again

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.my_key_pair: Refreshing state... [id=rockholla-di-force]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair must be replaced
-/+ resource "aws_key_pair" "my_key_pair" {
      ~ arn         = "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force" -> (known after apply)
      ~ fingerprint = "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62" -> (known after apply)
      ~ id          = "rockholla-di-force" -> (known after apply)
        key_name    = "rockholla-di-force"
      ~ key_pair_id = "key-006446b088b64a629" -> (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 force+di@rockholla.org" # forces replacement
      - tags        = {} -> null
    }

Plan: 1 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Well, turns out no matter what, for this type of resource, even an import leaves us in a place where the resource is going to be created anew, replaced anyway, namely b/c the import command didn't fill in all of the values in state from the actual resource, if we look back at our state introspection after the import:

```
"attributes": {
  "arn": "arn:aws:ec2:us-west-1:946320133426:key-pair/rockholla-di-force",
  "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
  "id": "rockholla-di-force",
  "key_name": "rockholla-di-force",
  "key_name_prefix": null,
  "key_pair_id": "key-006446b088b64a629",
  "public_key": null,
  "tags": {}
},
"private": "eyJzY2hlb
```

So, caveats exist for import. EC2 instances happen to not be subject to this sort of thing as long as you're filling values back in on the configuration side of things, so it will very much depend on the resource type as to whether or not import is going to be a good fit. Knowing the limitations of import are as important as understanding that it's there and how to use it.

## Let's finish off by running a destroy

```
$ terraform destroy
...
```
