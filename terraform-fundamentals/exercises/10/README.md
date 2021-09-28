# Exercise #10: Backends and Remote State

By Default, Terraform will store the state for you infrastructure in a local file, but there's a problem with this:

What if you work on a team where different people will run terraform at different times from different places? This
would mean you'd need to share your state file in some way. Some people have done it as encrypted local files in source
control, but this is generally not maintainable or scalable. So, enter the idea of central remote options for storing
your state files.

Since this course is about Terraform in AWS specifically, let's look at a relevant option that Terraform provides: S3

Storing Terraform state in an S3 bucket is as simple as making sure the bucket exists, and then defining an appropriate
configuration in your Terraform HCL:

```hcl
terraform {
  backend "s3" {
    bucket  = "REPLACE-WITH-YOUR-STATE-BUCKET-NAME"
    key     = "exercise-10/terraform.tfstate"
  }
}
```

_ASIDE: The above is the first time we're seeing the root `terraform` block. In many cases, it's sole use will
be for defining a remote backend, but it also allows you to do things like define a required terraform version via
semantic version syntax. See https://www.terraform.io/docs/configuration/terraform.html for more info_

If we look at the s3 backend definition above, what we see are two things that define where state should exist:

1. The S3 bucket where to put or find the state
1. The `key` or path within that bucket to the state file

Without further ado, let's try some of this out

### First, we need to make sure our state bucket exists

We'll actually create the state bucket through Terraform

```bash
cd state-bucket
terraform init
terraform apply
```

The output of the apply above should be something like

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.state_bucket will be created
  + resource "aws_s3_bucket" "state_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = "tf-fundys-finn-the-human-"
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.state_bucket: Creating...
aws_s3_bucket.state_bucket: Creation complete after 5s [id=tf-fundys-bane-20190623022126911700000001]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

state_bucket_name = tf-fundys-bane-20190623022126911700000001
```

Now, before we move on, you may be asking yourself: so what about the state for this state bucket? And it's a good
question. In this case, we're just accepting that we're maintaining a local state for the bucket itself. There are a
number of different paths you can take here including just ensuring that the bucket exists manually. The general idea
is that whatever manages this state bucket, be it manual or automated, should be by itself, easily recreateable and
not buried in a bunch of other automation.

Copy the value of your `state_bucket_name` output from the output of your apply, we'll use it for setting the remote
backend configuration.

### Now using our state bucket for the rest of our terraform

Now that our state bucket is there, we can actually start using it, so from this directory

```bash
# get back to the root folder of this exercise
cd ..
terraform init -backend-config=backend.tfvars
```

The above will prompt you for the backend bucket name to use

```
Initializing the backend...
bucket
  The name of the S3 bucket

  Enter a value:
```

You'll want to enter the bucket name that was output from your `state-bucket` terraform run.

Let's just focus on this slightly-different init command. It accepts backend configuration variables. The
terraform settings and backend configuration block in a .tf file **CANNOT** accept or process interpolations. We can,
however, still parameterize this stuff. This is particularly useful for things like secrets or other secure stuff
you might pass into backend configuration. You can store it temporarily outside of your infrastructure code and
simply instruct Terraform to use these values.

Now let's move on to our plan and apply

```bash
terraform plan -out=run.plan
```

For fun, we've thrown in an explicit saving of the plan to a file, and then applying that plan. Recent versions of
Terraform have automated similar processes, so in most cases, just running `terraform apply` will ensure that it runs
a plan and then asks you to accept that plan before continuing. This alternative method affords another way that was
previously considered best practice and continues to be a good option for more-automated terraform execution scenarios
like CI/CD pipelines for recording the plan artifact as an example.

The plan having been saved to the `run.plan` file, we can execute our apply to point to that plan

```
terraform apply run.plan
```

And you should get something similar to below

```
aws_s3_bucket_object.user_student_alias_object: Creating...
aws_s3_bucket_object.user_student_alias_object: Creation complete after 1s [id=student.alias]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

Pretty similar outcome as far as the "infrastructure" is concerned. But, let's finish off by taking a closer look at the
state since it now exists remotely. You can either head over the S3 area of the AWS console and navigate to your state bucket
to look around, or you could just use the aws cli to look as well:

```bash
aws s3 ls s3://[your s3 state bucket name]/exercise-10/
```

which should show you something like

```
2019-06-22 20:35:33       1186 terraform.tfstate
```

Your state file is appropriately stored in this remote location. Remote state isn't the extent of things teams need to do to
address safe and maintainable collaboration on infrastructure using terraform. Another is state locking, such as the case of:

* April is testing some changes to the terraform source to remove a DB instance that is no longer needed against the staging infrastructure
* At the same time, Chloe is running the current version of the terraform code against staging to test some other things out, but her changes still have the DB that April is removing. April's removal might go through, but then the DB is immediately recreated by Chloe's run. So, April might be scratching her head in 10 minutes wondering how that DB is suddenly there again

Locking the state file can address situations like the above and many other problematic scenarios in team collaboration using Terraform. We won't go into the details of state locking as an exercise. The thing that's important to know for the sake of this course around remote state locking:

* The S3 backend has built-in support for state locking
* It supports this locking through a Dynamo DB table

The above can simply be accomplished via the backend config like the following:

```hcl
terraform {
  backend "s3" {
    encrypt         = true
    bucket          = "REPLACE-WITH-YOUR-STATE-BUCKET-NAME"
    dynamodb_table  = "terraform-state-lock-dynamo"
    region          = us-east-2
    key             = "exercise-10/terraform.tfstate"
  }
}
```

If we have time at the end of the class, we can look at this more closely if folks are interested. Feel free to ask questions about it.

### Finishing up this exercise

Again, let's make sure we destroy everything we've created here

```bash
terraform destroy
cd state-bucket
terraform destroy
```
