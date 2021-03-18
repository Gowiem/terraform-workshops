# Exercise 6: Providers

Some of the more-complex provider situations include:

* Multiple versions of the same provider to support things like a single project that needs to support managing resources in multiple regions
* Hybrid cloud projects where you're managing infrastructure in a single project across multiple clouds
* Many providers in the same project and the organizational concerns since these projects tend to be large ones naturally

We'll work and think through some approaches to each of the above here, while also getting some hands-on experience with alternate providers like the [Template](https://registry.terraform.io/providers/hashicorp/template/latest/docs) one.

## Managing resources across multiple AWS regions in a single project

We've set up a project directory here in this exercise for this section: `./aws-multi-region`. Switch to that directory, and we'll begin.

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.70.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

The same init result we've seen for a few exercises. We're using a remote s3 bucket yet again here. Let's look at our source now to see what we have:

```
terraform {
  backend "s3" {}
}

provider "aws" {}

provider "aws" {
  region  = var.secondary_region
  alias   = "secondary_region"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-intermediate-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}@masterpoint.io"
}

resource "aws_key_pair" "my_key_pair_secondary_region" {
  key_name   = "tf-intermediate-${var.student_alias}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 ${var.student_alias}@masterpoint.io"
  provider   = aws.secondary_region
}
```

So, let's talk through this. First, we have two different providers of the same type. This is strictly so that we can create resources in multiple AWS regions. If we didn't include the `alias` argument to the second provider definition, terraform would error out. The support for this is strictly based on aliasing so that we can provide some instruction to resources or modules about what provider config to actually use.

We have our alias `secondary_region` provider for aws. Which means we can override resources to use this provider instead of the default one which is

```
provider "aws" {}
```

and, as a refresher, we're not setting the region on this default provider block, which means it'll use the `AWS_DEFAULT_REGION` environment variable as the region that we set up when we initialized our Cloud9 server environment. If that environment variable weren't set, we'd be prompted for the region to use for that block.

So, we can use our secondary provider accordingly along with our default one, but we need to tell resources or modules to use this provider instead of our default.

The `provider = aws.secondary_region` within the `aws_key_pair` resource is called a meta-argument, or some argument that terraform core defines common to all resource types. Any resource types support this argument, instructing it to use an alternate provider config instead of the default one setup up by the default provider block for that resource type. I encourage you to look at and experiment more with meta arguments [for resources](https://www.terraform.io/docs/language/resources/syntax.html#meta-arguments), [data sources](https://www.terraform.io/docs/configuration/data-sources.html#meta-arguments), and [modules](https://www.terraform.io/docs/language/modules/syntax.html#meta-arguments) during experimentation time today.

Let's go ahead and apply this configuration and see what happens

```
$ terraform apply
var.student_alias
  Your student alias

  Enter a value: luke-skywalker


An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_key_pair.my_key_pair will be created
  + resource "aws_key_pair" "my_key_pair" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
    }

  # aws_key_pair.my_key_pair_secondary_region will be created
  + resource "aws_key_pair" "my_key_pair_secondary_region" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "tf-intermediate-luke-skywalker"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.my_key_pair: Creating...
aws_key_pair.my_key_pair_secondary_region: Creating...
aws_key_pair.my_key_pair: Creation complete after 0s [id=tf-intermediate-luke-skywalker]
aws_key_pair.my_key_pair_secondary_region: Creation complete after 0s [id=tf-intermediate-luke-skywalker]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Great, both of our key pair resources were created. Though we don't have clear indication of the different regions where these key pairs were created from the resource/provider output here, we can be pretty confident that they are indeed in different regions, otherwise AWS would've given us an error attempting to create two key names of `tf-intermediate-[student-alias]` in the same region. For fun though, let's see if we can find out any more info, maybe see if we can see the region for these resources from state:

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 0,
  "lineage": "00be34b3-000f-1710-d00d-647d82ee5a6d",
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
            "arn": "arn:aws:ec2:us-west-2:946320133426:key-pair/tf-intermediate-luke-skywalker",
            "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
            "id": "tf-intermediate-luke-skywalker",
            "key_name": "tf-intermediate-luke-skywalker",
            "key_name_prefix": null,
            "key_pair_id": "key-09a95df5759e342c2",
            "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 luke-skywalker@masterpoint.io",
            "tags": null
          },
          "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_key_pair",
      "name": "my_key_pair_secondary_region",
      "provider": "provider.aws.secondary_region",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "arn": "arn:aws:ec2:us-east-2:946320133426:key-pair/tf-intermediate-luke-skywalker",
            "fingerprint": "d7:ff:a6:63:18:64:9c:57:a1:ee:ca:a4:ad:c2:81:62",
            "id": "tf-intermediate-luke-skywalker",
            "key_name": "tf-intermediate-luke-skywalker",
            "key_name_prefix": null,
            "key_pair_id": "key-0f3a754df2ad5f5fe",
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

Ah, so our arns for the key pairs verify the region for each key!

**Please destroy before moving to the next section**

```
$ terraform destroy
...
```

## Using the Template provider

OK, back to hands-on. Let's become familiar with the template provider. This is one that's foundational to terraform, useful in many situations, and quite simple.

Change your directory to the `./template-provider` one here. Looking at the contents of main.tf, do you think we need to run `terraform init`?

The answer is yes. Because we're using a provider, and thus a plugin requires `terraform init`, so let's run it:

```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "template" (hashicorp/template) 2.1.2...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

So, we've downloaded the template provider plugin, just like we've done so for the AWS one. They're all just plugins. And depending on our project we may or may not need them. For the template one we've got it locally:

```
$ ls -la .terraform/plugins/linux_amd64/
total 46168
drwxr-xr-x  4 gowiem  staff       128 Aug  7 20:39 .
drwxr-xr-x  3 gowiem  staff        96 Aug  7 20:39 ..
-rwxr-xr-x  1 gowiem  staff        84 Aug  7 20:39 lock.json
-rwxr-xr-x  1 gowiem  staff  23630632 Aug  7 20:39 terraform-provider-template_v2.1.2_x4
```

And so further Terraform commands are ready to use the plugin. So let's review the source first, all in main.tf


```
variable "network_on" {
  type    = bool
  default = false
}

variable "enable_security" {
  type      = bool
  default   = true
}

provider "template" {}

data "template_file" "config" {
  template = file('template.tmpl)
  vars = {
    network_on       = var.network_on
    enable_security  = var.enable_security
  }
}

output "template_rendered" {
  value = data.template_file.config.rendered
}

```


We have some input variables, they get passed in to the template, and rendered accordingly to produce a string. In most cases, this sort of thing is used for resources like `aws_instance` and it's [user_data argument](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#user_data). But it can be useful for anytime you need to build templated multi-line content.

Let's look at it as as standard terraform output nonetheless...

```
$ terraform apply
data.template_file.config: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

template_rendered = {
  "enable_network"  = "false",
  "enable_security" = "true"
}
```

Depending on the template structure, Terraform may parse and render structured data, or just a string. We can see in this case, that we actually see Terraform rendering something of a structured data item as an output. When you pass this same thing to other arguments of Terraform resources that accept only string, say, user-data for an ec2-instance, Terraform will type-convert and handle that gracefully.

## Best practices related to providers and modules

Hashicorp does a good job of telling us what we need to know, so I'll let you read what they thing on this subject:

[Hashicorp's recommendation on modules, providers, and what level should be responsible for what](https://www.terraform.io/docs/language/modules/develop/providers.html)

For projects using modules within modules within modules that only care about a single provider, some of this becomes less important, especially if it's all internally managed. Hopefully you can see how it could become an important topic as you adopt a number of providers in a single project using any number of modules or modules within modules dependent upon those providers.

Obviously, given a module and the way that it's written may require some version constraint of a provider. The above does not limit this. And a new concept to look at related to this is the root `terraform` block [`required_providers`](https://www.terraform.io/docs/configuration/terraform.html#specifying-required-provider-versions) argument.

As an example, let's look at an official, community provided module that clarifies this point. The [terraform-aws-vpc module](https://github.com/cloudposse/terraform-aws-vpc) defines [something at the terraform block level that tells any project using this module that they must be using the aws provider, and that project's definition of the provider either implicitly or explicitly must match the version constraint `>= 2.0`](https://github.com/cloudposse/terraform-aws-vpc/blob/master/versions.tf#L5). Projects using this module can still either implicitly or explicitly pass in the AWS provider configuration they define. The module-level terraform configuration block will halt any parent project using the module if it does not use the correct version, just as it would halt if the terraform CLI version being used was not acceptable.

## Hybrid cloud project structures, managing projects that are concerned with many providers

We're not going to get hands-on with this section, rather talk about some things conceptually, since this deals more with concerns at an architectural level.

Honestly, the most appropriate general approach to solving the considerations of this section are splitting up concerns into modules and making projects less monolithic. Let's look at an example project:

The project would be one that, say, manages resources of all the following types:

* AWS EC2
* AWS IAM
* AWS RDS
* AWS DynamoDB
* On-prem MySQL
* On-prem Web servers via a custom provider
* Azure VMs
* Google Cloud VMs
* Google Cloud IAM

Now, putting all of these concerns into a single project should immediately raise red flags. How might we split this up to distribute maintenance responsibilities and keeping efforts isolated and limited across teams? There are obviously dozens if not endless approaches, but let me present one based on a hypothetical organizational structure:

The teams:
* **Compute Ops and Admins**: those in charge of managing compute resources, so those things that are standard VMs, web servers, etc.
* **DB Ops and Admins**: the team managing database-related resources
* **Security Ops and Admins**: managing resources related to security both on-prem and in the cloud
* **Integrations Team**: defining and implementing what makes up a given system, set of systems for the org, environment-wide concerns, etc.

So, with this team structure, we might assign responsibility like the following. Image each team managing 1 or many modules to aid the integrations team in wiring it all up quite easily:

* **Compute Ops and Admins**
    * AWS EC2
    * On-prem Web servers
    * Azure VMs
    * Google Cloud VMs
* **DB Ops and Admins**
    * AWS RDS
    * AWS DynamoDB
    * On-prem MySQL
* **Security Ops and Admins**
    * AWS IAM
    * Google Cloud IAM

Now, the **Integrations Team** needs only piece together a few simple simple projects to pull in and consume the modules developed and made available by those other teams. You hope the interface is simple, and the modules are easy to implement. That's the goal, and if you do it right, you've turned something quite complex into a manageable division of responsibility, labor, and maintenance.

That's it for this exercise. A little more reading and digesting on this one as opposed to hands-on. But, it's worth it to take the time for these things as we advance in Terraform and tech knowledge generally.
