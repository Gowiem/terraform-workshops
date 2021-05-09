# Exercise #5: Interacting with Providers

Providers are plugins that Terraform uses to understand various external APIs and cloud providers.  Thus far in this
workshop, we've used the AWS provider. In this exercise, we're going to modify the AWS provider we've been
using to create our bucket in a different region.

### Add the second provider

Add this variable block to the "variables.tf" file:

```hcl
variable "region_alt" {
  default = "us-west-2"
}
```

Then, add this provider block with the new region to `main.tf` just under the existing provider block. Note the `alias` argument–this is necessary when you have duplicate providers:

```hcl
provider "aws" {
  region  = var.region_alt
  alias   = "alternate"
}
```

You will also need to specify the alternate provider when creating your bucket:

```hcl
resource "aws_s3_bucket" "student_bucket_alt" {
  bucket   = "tf-fundys-${var.student_alias}-alt"
  provider = aws.alternate
}
```

Now, let's provision and bring up another s3 bucket in this other region

```bash
terraform init
terraform apply
terraform show
```
The above should show that you have a bucket now named `tf-fundys-[your student alias]-alt` that was created in the
us-west-2 region.

**NOTE:** the `AWS_DEFAULT_REGION` environment variable is set in your Cloud9 environment as part of creating it.
Along with this variable and the access key and secret key, terraform is able to use these environment variables for the default AWS
provider (non-aliased provider) as defaults unless you override them in the provider block.

We'll be looking more at using providers in other exercises as we move along.

### Finishing this exercise

Let's run the following to finish:

```
terraform destroy
```
