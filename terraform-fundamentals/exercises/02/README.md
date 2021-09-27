# Exercise #2: Using Variables

For this exercise, we will revisit the terraform project from the previous exercise. There are a few ways
to accomplish our goal in this exercise, so try doing each one independently. If you get stuck or have
questions, let your instructor know.

There are many schools of thought on how to use variables to configure reusable terraform,
but we'll be exploring the core mechanics so that you can get a grasp of how to use them in various ways.

### Looking at the variable block

In order to leverage the mechanics around the variable concept in terraform, you must declare each variable.

We have a single variable defined in our `variables.tf` file as:

```hcl
# Declare a variable so we can use it.
variable "student_alias" {
  description = "Your student alias"
}
```

*Note: We don't have to have a variables.tf file – we could just as well put all variables, resources,
outputs, etc. into one file, but it's considered best practice to maintain different files for variables,
outputs, and resources.

The name of the variable above would be `student_alias`.

The possible properties of a variable:

1. `default`: allows for setting a default value, otherwise terraform requires it to be set:
    * via the CLI (`-var student_alias=my-alias`),
    * defined in a *.tfvars file
    * defined in an environment variable like `TF_VAR_[variable name]`
    * or it will prompt for the input
2. `description`: a useful summary of what the variable does
3. `type`: we'll discuss types in depth later

We've only set the description, so there's no default value, and it will use the default type of: `string`.

### Adding the values statically in the variables block.

You might notice that there is no "value" parameter in the syntax for the variable object.
This is because the variables blocks are not meant to be inputs themselves, but rather placeholders
that handle input and allow for reference throughout the working directory.  Though it is true that
variable blocks can be used this way by simply setting the "default" to the desired value, this
negates the benefits of Terraform's native re-usability.  Instead, try using one of the below methods.


### Initialization

Every time a new terraform working directory is created, we need to initialize it to prepare it to run against
the designated external API.  This does not need to happen after the first apply, just for new working directories.
Before continuing, make sure you're in the same directory as this `README.md` file.

```bash
terraform init
```

you should get an output similar to this:

```
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (terraform-providers/aws) 3.24.1...

Terraform has been successfully initialized!

...
```

The init method picked up on the fact that we had a reference to AWS resources in our HCL. Namely, that we defined
the AWS provider

```hcl
provider "aws" {}
```

One of init's jobs here is to ensure that it downloads the necessary providers to the `.terraform` directory
locally so that further plans and applies can use it. We'll get into providers later in the course.

## Ways to pass variable values to Terraform

### tfvars file

In each terraform working directory, there can be a file named `terraform.tfvars` (or `*.auto.tfvars`) that contains
HCL that defines values for variables for that working directory.  tfvar files can also be referenced via command line.

Let's try a few things.

* create a file called terraform.tfvars in this directory
* insert the following code into it:
```hcl
# swap "<YOUR ALIAS> with your full name in kebab case. e.g. "Luke Skywalker" => "luke-skywalker"
student_alias = "<YOUR ALIAS>"
```
* then run this in the same directory
```bash
terraform plan
```

You should see that the terraform plan output includes an s3 bucket, and that the value for `bucket_name`
utilizes your chosen identifying text.

Remove your `terraform.tfvars` file so we can look at other ways of passing in the variable:

```
rm terraform.tfvars
```

### Command Line Arguments

Another method you can use is to insert variables via the CLI.  This allows for quick variable substitution and
testing because values entered via CLI override values from other methods.

* run the following in this working directory (if you were able to complete the previous), swapping for your
identifier like before.

```bash
terraform plan -var 'student_alias=<YOUR ALIAS>'
```

* You can try using a different identifier to see if it worked. Like before, you should be able to see the
new identifier in the plan output.

### Using Environment variables

Environment variables can be used to set the value of an input variable in the root module. The name of the
environment variable must be `TF_VAR_` followed by the variable name, and the value is the value of the variable.

Try the following:

```bash
TF_VAR_student_alias=$YOUR_ALIAS terraform plan
```

This can be a useful method for secrets handling, or other automated use cases.

### Prompt for a variable value

Try just running the plan without having a pre-populated value set, see what happens:

```
terraform plan
```

The above should prompt you for your `student_alias` value. The final way in which a variable can be set at runtime.

### Locals

A related concept that we'll get into a bit more a little later is something called a local. Locals act like variables,
in that they can be referenced from multiple locations, but locals can't take inputs like variables. Locals also allow for
interpolation, like merging strings or basing a value on chained dependencies of locals. Locals act more similiarly to
the standard variable you might be working with in Python, for example.  Here is an example:

```hcl
locals {
  title = "Student"
  name = "${var.student_alias}"
  name_and_title = "${local.name} - ${local.title}"
}
```

This is where we'll stop for now. We'll begin actually working with applying these plans in our next exercise.

