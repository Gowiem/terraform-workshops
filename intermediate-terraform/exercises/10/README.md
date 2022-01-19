# Exercise 10: Terraform Import

Remember when we used `terraform state rm` yesterday to essentially abandon a resource from Terraform's control? We're going to do the same thing here so we can import the disconnected infrastructure

## Create our infrastructure item to abandon

Let's init and do an apply to create the Elastic Container Repository (ECR) repo resource defined in this project

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
...
$ terraform apply

var.student_alias
  Your student alias

  Enter a value: luke-skywalker


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ecr_repository.student_repo will be created
  + resource "aws_ecr_repository" "student_repo" {
      + arn                  = (known after apply)
      + id                   = (known after apply)
      + image_tag_mutability = "MUTABLE"
      + name                 = "luke-skywalker-repo"
      + registry_id          = (known after apply)
      + repository_url       = (known after apply)
      + tags_all             = (known after apply)

      + image_scanning_configuration {
          + scan_on_push = true
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_ecr_repository.student_repo: Creating...
aws_ecr_repository.student_repo: Still creating... [10s elapsed]
aws_ecr_repository.student_repo: Creation complete after 16s [id=luke-skywalker-repo]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Alright, so we now have an ECR repo created up on AWS. We want to abandon it from our Terraform state so that we can see `terraform import` in action

First, though, let's figure out the ECR repo's `name` by looking at our current state

```
$ terraform show

# aws_ecr_repository.student_repo:
resource "aws_ecr_repository" "student_repo" {
    arn                  = "arn:aws:ecr:us-east-2:146525114093:repository/luke-skywalker-repo"
    id                   = "luke-skywalker-repo"
    image_tag_mutability = "MUTABLE"
    name                 = "luke-skywalker-repo"
    registry_id          = "146525114093"
    repository_url       = "146525114093.dkr.ecr.us-east-2.amazonaws.com/luke-skywalker-repo"
    tags_all             = {}

    encryption_configuration {
        encryption_type = "AES256"
    }

    image_scanning_configuration {
        scan_on_push = true
    }
}
```

Noting the `id` attribute value here, as we'll need it for our import. We'll go ahead and abandon it from our state.

```
$ terraform state rm aws_ecr_repository.student_repo
Removed aws_ecr_repository.student_repo
Successfully removed 1 resource instance(s).
```

And now let's have a look at our current state:

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "0.12.31",
  "serial": 1,
  "lineage": "bd7ae852-5916-7269-4d2e-6eb4d19808ae",
  "outputs": {},
  "resources": []
}
```

Cool, the resource still exists out there and [we can see it by going to the ECR console](https://us-east-2.console.aws.amazon.com/ecr/repositories?region=us-east-2), but the state for our project doesn't know about it. Let's get it back into state with an import.

Let's take a moment to look at the help for the import command at this stage:

```
$ terraform import --help
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
resource "aws_ecr_repository" "student_repo" {}
```

So, we have a resource defined, a placeholder for some real piece of infrastructure we want to import, and an ECR repo that exists in AWS.

Now, the `ID` part noted in the usage of the help. What this is very much depends on the type of resource. For an EC2 instance, it'll be the instance ID as defined by AWS, in our case for a ECR repo, it'll be the resource `name` we noted in our terraform show above. So, let's try the import as we should have everything we need to do so.

```
$ terraform import aws_ecr_repository.student_repo <YOUR ECR REPO ID>
aws_ecr_repository.student_repo: Importing from ID "<YOUR ECR REPO ID>"...
aws_ecr_repository.student_repo: Import prepared!
  Prepared aws_ecr_repository for import
aws_ecr_repository.student_repo: Refreshing state... [id=<YOUR ECR REPO ID>]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

Excellent, so it's seemingly now imported and part of our project state yet again. Let's verify that

```
$ terraform state pull
{
  "version": 4,
  "terraform_version": "1.0.0",
  "serial": 2,
  "lineage": "e5db200b-8ef7-9815-5c53-b16631f64821",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_ecr_repository",
      "name": "student_repo",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "arn": "arn:aws:ecr:us-east-2:146525114093:repository/luke-skywalker-repo",
            "encryption_configuration": [
              {
                "encryption_type": "AES256",
                "kms_key": ""
              }
            ],
            "id": "luke-skywalker-repo",
            "image_scanning_configuration": [
              {
                "scan_on_push": true
              }
            ],
            "image_tag_mutability": "MUTABLE",
            "name": "luke-skywalker-repo",
            "registry_id": "146525114093",
            "repository_url": "146525114093.dkr.ecr.us-east-2.amazonaws.com/luke-skywalker-repo",
            "tags": {},
            "tags_all": {},
            "timeouts": {
              "delete": null
            }
          },
          "sensitive_attributes": [],
          "private": "eyJlMmJmYjczMC1lY2FhLTExZTYtOGY4OC0zNDM2M2JjN2M0YzAiOnsiZGVsZXRlIjoxMjAwMDAwMDAwMDAwfSwic2NoZW1hX3ZlcnNpb24iOiIwIn0="
        }
      ]
    }
  ]
}
```

Nice, but we have an empty block in our configuration. What would happen if I ran an apply now without filling things back out appropriately in the resource definition block?

```
$ terraform plan

var.student_alias
  Your student alias

  Enter a value: luke-skywalker

╷
│ Error: Missing required argument
│
│   on main.tf line 9, in resource "aws_ecr_repository" "student_repo":
│    9: resource "aws_ecr_repository" "student_repo" {}
│
│ The argument "name" is required, but no definition was found.
```

OK, yeah we're missing a required argument in the resource itself. We have to fill this back in. In practice, this is usually just done after an import by looking at the state and setting the configuration values appropriately. Hashicorp notes that at some point in the future Terraform will be able to fill in and modify configuration after an import as well. For now, though, it's on us to do so. Let's get values back in:

```
resource "aws_ecr_repository" "student_repo" {
  name                 = "${var.student-alias}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

And we'll try a terraform plan again

```
$ terraform plan
var.student_alias
  Your student alias

  Enter a value: luke-skywalker

aws_ecr_repository.student_repo: Refreshing state... [id=luke-skywalker-repo]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

So, caveats exist for import. EC2 instances happen to not be subject to this sort of thing as long as you're filling values back in on the configuration side of things, so it will very much depend on the resource type as to whether or not import is going to be a good fit. Knowing the limitations of import are as important as understanding that it's there and how to use it.

## Let's finish off by running a destroy

```
$ terraform destroy -auto-approve
var.student_alias
  Your student alias

  Enter a value: luke-skywalker

aws_ecr_repository.student_repo: Refreshing state... [id=luke-skywalker-repo]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_ecr_repository.student_repo will be destroyed
  - resource "aws_ecr_repository" "student_repo" {
      - arn                  = "arn:aws:ecr:us-east-2:146525114093:repository/luke-skywalker-repo" -> null
      - id                   = "luke-skywalker-repo" -> null
      - image_tag_mutability = "MUTABLE" -> null
      - name                 = "luke-skywalker-repo" -> null
      - registry_id          = "146525114093" -> null
      - repository_url       = "146525114093.dkr.ecr.us-east-2.amazonaws.com/luke-skywalker-repo" -> null
      - tags                 = {} -> null
      - tags_all             = {} -> null

      - encryption_configuration {
          - encryption_type = "AES256" -> null
        }

      - image_scanning_configuration {
          - scan_on_push = true -> null
        }

      - timeouts {}
    }

Plan: 0 to add, 0 to change, 1 to destroy.
aws_ecr_repository.student_repo: Destroying... [id=luke-skywalker-repo]
aws_ecr_repository.student_repo: Still destroying... [id=luke-skywalker-repo, 10s elapsed]
aws_ecr_repository.student_repo: Destruction complete after 11s

Destroy complete! Resources: 1 destroyed.
```
