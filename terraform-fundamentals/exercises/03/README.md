# Exercise #3: Plans and Applies

So now we are actually going to get into it and create some infrastructure! For this exercise, we are going to:

1. Initialize our project directory (i.e., this exercise directory)
1. Run a plan to understand why planning makes sense, and should always be a part of your terraform flow
1. Actually apply our infrastructure, in this case a single object within our s3 bucket
1. Destroy what we stood up

### Initialization

First, we need to run init since we're starting in a new exercise, or project directory:

```bash
terraform init
```

### Plan

Next step is to run a plan, which is a dry run that helps us understand what terraform intends to change when it
runs an apply.

Remember from the previous exercise that we'll need to make sure our `student_alias` value gets passed in appropriately.
Pick whichever method of doing so, and then run your plan:

```bash
terraform plan
```

Your output should look something like this:

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket_object.user_student_alias_object will be created
  + resource "aws_s3_bucket_object" "user_student_alias_object" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-..."
      + content                = "This bucket is reserved for ..."
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "student.alias"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

From the above output, we can see that terraform will create a single S3 object in our bucket.  An important line
to note is the one beginning with "Plan:".  We see that 1 resource will be created, 0 will be changed, and 0 destroyed.

Terraform is designed to detect when there is configuration drift in resources that it created and then intelligently
determine how to correct the difference. This will be covered in more detail a little later.

### Apply

Let's go ahead and let Terraform create the S3 bucket object. Maybe try a different method of passing in your `student_alias`
variable when running the apply:

```bash
terraform apply
```

Terraform will execute another plan, and then ask you if you would like to apply the changes. Type "yes" to approve, then
let it do its magic.  Your output should look like the following:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket_object.user_student_alias_object will be created
  + resource "aws_s3_bucket_object" "user_student_alias_object" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-..."
      + content                = "This bucket is reserved for ..."
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "student.alias"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket_object.user_student_alias_object: Creating...
aws_s3_bucket_object.user_student_alias_object: Creation complete after 1s [id=student.alias]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Awesome, we've succesfully applied our Terraform infrastructure and created a resource, easy!

Now let's run a plan again and see what happens:

```bash
terraform plan
```

You should notice a couple differences:

* Terraform informs you that it is Refreshing the State.
    * after the first apply, any subsequent plans and applies will check the infrastructure it created and updates the terraform state with any new information about the resource.
* Next, you'll notice that Terraform informed you that there are no changes to be made.  This is because the infrastructure was just created and there were no changes detected.

### Handling Changes

Now, let's try making a change to the s3 bucket object and allow Terraform to correct it.  Let's change the content of our object.

Find `main.tf` and modify the s3 bucket block to reflect the following (add the `****ONLY****` bit to the end of the content string):

```hcl
# declare a resource block so we can create something.
resource "aws_s3_bucket_object" "user_student_alias_object" {
  bucket  = "tf-fundys-${var.student_alias}"
  key     = "student.alias"
  content = "This bucket is reserved for ${var.student_alias} ****ONLY****"
}
```

Now run another apply:

```bash
terraform apply
```

The important output for the plan portion of the apply that you should note, something that looks like:

```
Terraform will perform the following actions:

  # aws_s3_bucket_object.user_student_alias_object will be updated in-place
  ~ resource "aws_s3_bucket_object" "user_student_alias_object" {
        acl           = "private"
        bucket        = "tf-fundys-..."
      ~ content       = "This bucket is reserved for ..." -> "This bucket is reserved for ... ****ONLY****"
        content_type  = "binary/octet-stream"
        etag          = "94e32327b8007fa215f3a9edbda7f68c"
        id            = "student.alias"
        key           = "student.alias"
        storage_class = "STANDARD"
        tags          = {}
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

A terraform plan informs you with a few symbols to tell you what will happen

* `+` means that terraform plans to add this resource
* `-` means that terraform plans to remove this resource
* `-/+` means that terraform plans to destroy then recreate the resource
* `+/-` is similar to the above, but in certain cases a new resource needs to be created before destroying the previous one, we'll cover how you instruct terraform to do this a bit later
* `~` means that terraform plans to modify this resource in place (doesn't require destroy then re-create)
* `<=` means that terraform will read the resource

So our above plan will modify our s3 object in place per our requested update to the file.

Some resources or some changes require that a resource be recreated to facilitate that change, and those cases are usually expected. One example of this would be an AWS launch configuration. In AWS, launch configurations cannot be changed, only copied and modified once during the creation of the copy. Terraform is generally made aware of these caveats and
handles those changes gracefully, including updating dependent resources to link to the newly created resource. This
greatly simplifies complex or frequent changes to any size infrastructure and reduces the possibility of human error.

### Destroy

When infrastructure is retired, Terraform can destroy that infrastructure gracefully, ensuring that all resources
are removed and in the order that their dependencies require.  Let's destroy our s3 bucket object.

```bash
terraform destroy
```

You should get the following:

```
aws_s3_bucket_object.user_student_alias_object: Refreshing state... [id=student.alias]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_s3_bucket_object.user_student_alias_object will be destroyed
  - resource "aws_s3_bucket_object" "user_student_alias_object" {
      - acl           = "private" -> null
      - bucket        = "tf-fundys-..." -> null
      - content       = "This bucket is reserved for ... ****ONLY****" -> null
      - content_type  = "binary/octet-stream" -> null
      - etag          = "c7e49348083281f9dd997923fe6084b7" -> null
      - id            = "student.alias" -> null
      - key           = "student.alias" -> null
      - storage_class = "STANDARD" -> null
      - tags          = {} -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_s3_bucket_object.user_student_alias_object: Destroying... [id=student.alias]
aws_s3_bucket_object.user_student_alias_object: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

You'll notice that the destroy process is very similar to apply, just the other way around! And it also requires
confirmation, which is a good thing.

