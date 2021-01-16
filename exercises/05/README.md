# Exercise #5: Interacting with Providers

Providers are plugins that Terraform uses to understand various external APIs and cloud providers.  Thus far in this
workshop, we've used the AWS provider. In this exercise, we're going to modify the AWS provider we've been
using to create our bucket in a different region.

### Add the second provider

Add this variable stanza to the "variables.tf" file:

```hcl
variable "region_alt" {
  default = "us-west-2"
}
```

Then, add this provider block with the new region to `main.tf` just under the existing provider block. Note the `alias` argument–this is necessary when you have duplicate providers:

```hcl
provider "aws" {
  version = "~> 2.0"
  region = "${var.region_alt}"
  alias = "alternate"
}
```

You will also need to specify the alternate provider when creating your bucket:

```hcl
  provider = aws.alternate
```

Now, let's provision and bring up another s3 bucket in this other region

```bash
terraform init
terraform apply
terraform show
```
The above should show that you have a bucket now named `dws-di-[your student alias]-alt` that was created in the
us-west-2 region.

*NOTE:* that at the beginning of our course we set the `AWS_DEFAULT_REGION` environment variable in your Cloud9 environment.
Along with this variable and the access key and secret key, terraform is able to use these environment variables for the AWS
provider as defaults unless you override them in the HCL provider stanza.

We'll be looking more at using providers in other exercises as we move along.

### Finishing this exercise

Let's run the following to finish:

```
terraform destroy
```
