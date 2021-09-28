# Exercise #6: Modules

Terraform is *ALL* about modules.  Every terraform project / working directory is really just a module that could be reused by others
This is one of the key capabilities of Terraform.

In this exercise, we are going to modularize the code that we have been playing with during this whole workshop, but instead of
constantly redeclaring everything, we are just going to reference the module that we've created and see if it works.

First, create a main.tf file in the main directory for the 6th exercise.  Inside the `main.tf` file you created, please add the following:

```hcl
provider "aws" {}

module "s3_bucket_01" {
  source        = "./modules/s3_bucket/"
  region        = "us-east-2"
  student_alias = var.student_alias
}

# We're not defining region in this module call, so it will use the default as defined in the module
# What happens when you remove the default from the module and don't pass here? Feel free to try it out.
module "s3_bucket_02" {
  source        = "./modules/s3_bucket/"
  student_alias = var.student_alias
}
```

Next, create a `variables.tf` file so we can capture `student_alias` to pass it through to our module:

```hcl
variable "student_alias" {
  description = "Your student alias"
}
```

What we've done here is create a `main.tf` config file that references a module stored in a
local directory, twice.  This allows us to encapsulate any complexity contained by the module's code
while still allowing us to pass variables into the module.

After doing this, you can then begin the init and apply process.

```bash
terraform init
terraform plan
terraform apply
```

You'll notice that terraform manages each resource as if there is no module division, meaning the resources are bucketed
into one big change list, but under the covers Terraform's dependency graph will show some separation.

### Finishing this exercise

Let's run the following to finish:

```
terraform destroy
```
