# Exercise #9: Resource Counts and Conditional HCL

The idea of "looping" or repeated resource capabilities in Terraform is one of the most encountered gotchas.
Declarative infrastructure tools and languages often require or encourage more explicit definition of things
rather than supporting logic where other languages might have an "easier" way of doing things. Nonetheless,
there's still a good deal you can accomplish via Terraform's `count` concept that mimicks the idea of loops
and creating multiple copies or versions of a single thing.

Modules, as we saw, are another key aspect of reusability in Terraform.

But let's take a look at `count` in action for the sake of reusability and list of common infrastructure
objects, and related logical support for the sake of dynamic resource management.

Run the following in this directory

```bash
terraform init
terraform plan
```

You should see something like the following

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket_object.dynamic_file[0] will be created
  + resource "aws_s3_bucket_object" "dynamic_file" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-luke-skywalker"
      + content                = "dynamic-file at index 0"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "dynamic-file-0"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # aws_s3_bucket_object.dynamic_file[1] will be created
  + resource "aws_s3_bucket_object" "dynamic_file" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-luke-skywalker"
      + content                = "dynamic-file at index 1"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "dynamic-file-1"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # aws_s3_bucket_object.dynamic_file[2] will be created
  + resource "aws_s3_bucket_object" "dynamic_file" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-luke-skywalker"
      + content                = "dynamic-file at index 2"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "dynamic-file-2"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

  # aws_s3_bucket_object.optional_file[0] will be created
  + resource "aws_s3_bucket_object" "optional_file" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-luke-skywalker"
      + content                = "optional-file"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "optional-file"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### The `count` parameter

Let's look at the `main.tf` file here to see what's going on. First, the `aws_s3_bucket_object.dynamic_file` definition

```hcl
resource "aws_s3_bucket_object" "dynamic_file" {
  count   = var.object_count
  bucket  = "tf-fundys-${var.student_alias}"
  key     = "dynamic-file-${count.index}"
  content = "dynamic-file at index ${count.index}"
}
```

So, there's a variable controlling the number of `dynamic_file` objects that will actually be created, let's look at the
`variables.tf` file, and we see our `object_count` variable definition

```hcl
variable "object_count" {
  type        = number
  description = "number of dynamic objects/files to create in the bucket"
  default     = 3
}
```

And it has a default value of *3*, so our `aws_s3_bucket_object` resource uses the `count` property to dynamically define the number
of "copies" of this resource we'd like. This all adds up to our plan telling us that the following would be created:

```
aws_s3_bucket_object.dynamic_file[0] will be created
aws_s3_bucket_object.dynamic_file[1] will be created
aws_s3_bucket_object.dynamic_file[2] will be created
```

### Conditional HCL Resources

The count parameter, now in combination with the `bool` type is particularly useful for conditionally including
things in your ultimately built infrastructure. Let's look at our `main.tf` again to see an example

```hcl
resource "aws_s3_bucket_object" "optional_file" {
  count   = var.include_optional_file ? 1 : 0
  bucket  = "tf-fundys-${var.student_alias}"
  key     = "optional-file"
  content = "optional-file"
}
```

So, our `count   = var.include_optional_file ? 1 : 0` syntax says: if the `include_optional_file` variable is set to true, we
want one instance of this object, otherwise we want 0. Could you think of another way to produce the same result? Hint: it's how
you had to do it before the `bool` data type came around.

We see in our plan output

```
  # aws_s3_bucket_object.optional_file[0] will be created
  + resource "aws_s3_bucket_object" "optional_file" {
      + acl                    = "private"
      + bucket                 = "tf-fundys-luke-skywalker"
      + content                = "optional-file"
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + id                     = (known after apply)
      + key                    = "optional-file"
      + server_side_encryption = (known after apply)
      + storage_class          = (known after apply)
      + version_id             = (known after apply)
    }
```

And in our variables file

```hcl
variable "include_optional_file" {
  type        = bool
  default     = true
}
```

So, indeed our optional file/object would be created/maintained since we're using the default `include_optional_file=true`. Try
another plan, but with

```
terraform plan -var include_optional_file=false
```

Is it what you expected? If you have a little extra time, play around more with count and other ways that you might achieve
conditional logic in HCL. Ask questions if you have them.

Then, let's move on!
