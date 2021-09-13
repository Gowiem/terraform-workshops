# Exercise #7: Error Handling, Troubleshooting

We'll take some time to look at what the different types of errors we discussed look like. In each part of this
exercise you'll get a feel for some common error scenarios and how to fix or address them.

### Process Errors

So, as mentioned, process errors are really about just something problematic in way that terraform is being run.
So, what happens when you run `apply` before `init`? Let's run apply here before init:

```bash
terraform apply
```

You should see something like:

```
Error: Could not satisfy plugin requirements

Plugin reinitialization required. Please run "terraform init".

Plugins are external binaries that Terraform uses to access and manipulate
resources. The configuration provided requires plugins which can't be located,
don't satisfy the version constraints, or are otherwise incompatible.

Terraform automatically discovers provider requirements from your
configuration, including providers used in child modules. To see the
requirements and constraints from each module, run "terraform providers".



Error: provider.aws: no suitable version installed
  version requirements: "~> 2.0"
  versions installed: none
```

One of `init`'s jobs is to ensure that dependencies like providers, modules, etc. are pulled
in and available locally within your project directory. If we don't run `init` first, none of
our other terraform operations have all the requirements they need to do their job.

How about another process error example, the apply command has an argument that will tell it
to never prompt you for input variables: `-input=[true|false]`. By default, it's true, but we
could try running `apply` with it set to false.

```bash
terraform init


unset TF_VAR_student_alias && terraform apply -input=false
```

Which should give you something like:

```
Error: No value for required variable

  on variables.tf line 4:
   4: variable "student_alias" {

The root module input variable "student_alias" is not set, and has no default
value. Use a -var or -var-file command line argument to provide a value for
this variable.
```

Alright, pretty simple and straight forward to grasp, right? Let's move on.

### Syntactical Errors

Let's modify the `main.tf` file here to include something invalid. At the end of the file, add this:

```hcl
resource "aws_s3_bucket_object" "an_invalid_resource_definition" {
```

Clearly a syntax problem, so let's run

```
terraform plan
```

And you should see something like

```
Error: Argument or block definition required

  on main.tf line 17, in resource "aws_s3_bucket_object" "an_invalid_resource_definition":
  17:

An argument or block definition is required here.
```

The goal is to get used to what things look like depending on the type of error encountered. These syntax
errors happen early in the processing of Terraform commands.

### Validation Errors

This one might not be as clear as the syntax problem above. Let's pass something invalid
to the AWS provider by setting a property that doesn't jive with the `aws_s3_bucket_object`
resource as defined in the AWS provider. We'll modify the syntax issue above slightly, so change
your resource definition to be:

```hcl
resource "aws_s3_bucket_object" "an_invalid_resource_definition" {
  key     = "student.alias"
  content = "This bucket is reserved for ${var.student_alias}"
}
```

Nothing seemingly wrong with the above when looking at it, unless you know that the `bucket` property
is a required one on this type of resource. So, let's see what terraform tells us about this:

```bash
terraform validate
```

First, here we see the `terraform validate` command at work. We could just as easily do a `terraform plan`
and get a similar result. Two benefits of validate:

1. It allows validation of things without having to worry about everything we would in the normal process of plan or apply. For example, variables don't need to be set.
2. Related to the above, it's a good tool to consider for a continuous integration and/or delivery/deployment pipeline. Failing fast is an important part of any validation or testing tool.

If you were to have run `terraform plan` here, you would've still been prompted for the `student_alias` value
(assuming of course you haven't set it in otherwise).

Having run `terraform validate` you should see immediately something like the following:

```
Error: Missing required argument

  on main.tf line 17, in resource "aws_s3_bucket_object" "an_invalid_resource_definition":
  17: resource "aws_s3_bucket_object" "an_invalid_resource_definition" {

The argument "bucket" is required, but no definition was found.
```

So, our provider is actually giving us this. The AWS provider defines what a `aws_s3_bucket_object` should include,
and what is required. The `bucket` property is required, so it's telling us we have a problem with this resource defintion.

### Provider Errors or Passthrough

And now to the most frustrating ones! These may be random, intermittent and they will be very specific to the provider you're using. These problems happen when actually trying to do the work of setting up or maintaining your resources. Let's take a look at a simple example.
Modify the invalid resource we've been working with here in `main.tf` to now be:

```hcl
resource "aws_s3_bucket_object" "a_resource_that_will_fail" {
  bucket  = "a-bucket-that-doesnt-exist-or-i-dont-own"
  key     = "file"
  content = "This will never exist"
}
```

Then run

```
terraform apply
```

And you should see something like:

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket_object.a_resource_that_will_fail will be created
  + resource "aws_s3_bucket_object" "a_resource_that_will_fail" {
      + acl                    = "private"
      + bucket                 = "a-bucket-that-doesnt-exist-or-i-dont-own"
      + content                = "This will never exist"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "file"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # aws_s3_bucket_object.user_student_alias_object will be created
  + resource "aws_s3_bucket_object" "user_student_alias_object" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-luke-skywalker"
      + content                = "This bucket is reserved for luke-skywalker"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "student.alias"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket_object.a_resource_that_will_fail: Creating...
aws_s3_bucket_object.user_student_alias_object: Creating...
aws_s3_bucket_object.user_student_alias_object: Creation complete after 1s [id=student.alias]

Error: Error putting object in S3 bucket (a-bucket-that-doesnt-exist-or-i-dont-own): NoSuchBucket: The specified bucket does not exist
        status code: 404, request id: 13C49158C71AE950, host id: /b1aIUG6gMMiJCI2PBVKDoBcBmutIR/vMEqEeTTojSxj400e31jcsETZCOGxRGQ031ilI1QrcWY=

  on main.tf line 17, in resource "aws_s3_bucket_object" "a_resource_that_will_fail":
  17: resource "aws_s3_bucket_object" "a_resource_that_will_fail" {
```

Where is this error actually coming from? In this case, it's the AWS S3 API. It's trying to put an object to a bucket that
doesn't exist. Terraform is making the related API call to try and create the object, but AWS can't do it because the bucket
in which we're trying to put the object either doesn't exist or we don't own it, so we get this error passed back to us.

One other thing worth noting -- Did everything fail?

```
aws_s3_bucket_object.a_resource_that_will_fail: Creating...
aws_s3_bucket_object.user_student_alias_object: Creating...
aws_s3_bucket_object.user_student_alias_object: Creation complete after 1s [id=student.alias]

Error: Error putting object in S3 bucket (a-bucket-that-doesnt-exist-or-i-dont-own): NoSuchBucket: The specified bucket does not exist
        status code: 404, request id: 13C49158C71AE950, host id: /b1aIUG6gMMiJCI2PBVKDoBcBmutIR/vMEqEeTTojSxj400e31jcsETZCOGxRGQ031ilI1QrcWY=

  on main.tf line 17, in resource "aws_s3_bucket_object" "a_resource_that_will_fail":
  17: resource "aws_s3_bucket_object" "a_resource_that_will_fail" {
```

Nope! Our first bucket object that was valid was created, only the second one failed. Terraform will complete
what it can and fail on what it can't. Sometimes the solution to failures can sometimes just be running
the same Terraform multiple times (e.g., if there's a network issue between where you're running Terraform and AWS).

### Finishing this exercise

First, remove the offending HCL now in `main.tf`

```
resource "aws_s3_bucket_object" "a_resource_that_will_fail" {
  bucket  = "a-bucket-that-doesnt-exist-or-i-dont-own"
  key     = "file"
  content = "This will never exist"
}
```

And then

```
terraform destroy
```

