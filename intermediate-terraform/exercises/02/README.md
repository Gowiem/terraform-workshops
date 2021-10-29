# Exercise 2: Deeper Dive into Terraform Init

We've had a pretty good look at just about everything `terraform init` does, but there are just a few more things that we want to look more closely at in order to round out our knowledge of its capabilities and responsibilities.

## Managing Backend Configuration

Terraform backends are primarily about how it manages the state for your project. So, by default, Terraform will create and manage a state file that just lives locally within your project directory. A very important concept in Terraform is that this default, local state files, are not a best-practice when it comes to running and managing real Terraform projects. The reasons to avoid local state file management in real projects:

* it's quite hard to facilitate sharing state in team settings where multiple people or even multiple teams manage a particular project or set of infrastructure. State should instead be stored in some centralized place so that any operation run against the project will use an accurate, single-source-of-truth state
* related, it's all too easy to be working from an inaccurate state
* state files can contain sensitive data, so having them as local state files that might, say, be shared around in VCS or otherwise can be insecure

Enter Terraform backends so that we can centrally manage state for a project in some central location like an s3 bucket. There are a number of backend types available through different providers. We'll be working with the s3 bucket type for the remainder of this course. This backend type supports:

* storage of state files at a particular path in an s3 bucket
* encrypting state at rest in a bucket
* state file locking through use of DynamoDB table records, preventing race and conflicting conditions on terraform operations run against a particular state

### Using the s3 backend type

When your student alias user accounts were created before this course, an s3 bucket was also created for you named like `tf-intermediate-[student-alias]`. We'll be using these buckets that already exist as the place to store and manage your remote state as we move forward in this course. We'll be working primarily with realistic, remote state scenarios for the remainder of our exercises.

One quick aside before we get started working with this project. Notice the file structure introduced in this project:

```
.
├── README.md
├── backend.tfvars
├── ec2.tf
├── providers.tf
├── s3.tf
├── terraform.tf
└── variables.tf
```

We've gone even a bit further than we have previously to do some organization of files for purpose. This can be a useful approach, especially in projects that are large or that promise to be large eventually:

* `terraform.tf`: containing our root `terraform` block and its settings, root terraform configuration
* `providers.tf`: including any provider declaration/defintion blocks, as a project could contain 1 or many
* `ec2.tf`, `s3.tf`: a single `main.tf` or similar monolithic project config file might not be appropriate for larger projects. Splitting up by purpose can be a good pattern to follow. This is not entirely unlike the benefits of encapsulating concerns in modules.

OK, so we have a Terraform project, and we want to see how it's set up to use an s3 backend. We'll make sure it's configured correctly to do so for our student alias bucket and then create some infrastructure making use of our backend and remote state.

Let's first look at the contents of our root terraform block/settings in `terraform.tf`:

```
terraform {
  backend "s3" {}

  ...
}
```

This is telling terraform that we'll want to use a backend type of s3 to store our remote state. This block contains [various configuration options](https://www.terraform.io/docs/backends/types/s3.html), and we'll be including these options in a few different ways. If including in this `backend "s3"` block, note that **it does not support dynamic values or interpolation**, only hardcoded values. So, having other ways to set dynamic config is important.

One way we can do so is via a `backend.tfvars` file that we'll pass to the `terraform init` command. This option is similar to how we pass in variable values via tfvars files.

Another way we can do so is by passing values in directly to the `terraform init` command.

So, we'll utilize both methods above together in a single command. Make sure to replace `[student-alias]` in the command with your student alias:

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 3.31.0...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 3.31"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We can see in the output, that our init command has successfully prepped our project for use of the s3 remote backend as configured. Let's look more closely at what this actually did.

```
$ ls .terraform
plugins			terraform.tfstate
```

`.terraform/plugins` storing our provider plugins downloaded. `.terraform/terraform.tfstate` being a state pointer file that init set up for us based on the remote state backend config we provided. Let's look at that file.

```
{
    "version": 3,
    "serial": 1,
    "lineage": "6781e066-7ad5-a73a-fd2a-59a266052d20",
    "backend": {
        "type": "s3",
        "config": {
            "access_key": null,
            "acl": null,
            "assume_role_policy": null,
            "bucket": "tf-intermediate-luke-skywalker",
            "dynamodb_endpoint": null,
            "dynamodb_table": null,
            "encrypt": true,
            "endpoint": null,
            "external_id": null,
            "force_path_style": null,
            "iam_endpoint": null,
            "key": "intermediate-terraform/exercise-02/terraform.tfstate",
            "kms_key_id": null,
            "lock_table": null,
            "max_retries": null,
            "profile": null,
            "region": "us-east-2",
            "role_arn": null,
            "secret_key": null,
            "session_name": null,
            "shared_credentials_file": null,
            "skip_credentials_validation": null,
            "skip_get_ec2_platforms": null,
            "skip_metadata_api_check": null,
            "skip_region_validation": null,
            "skip_requesting_account_id": null,
            "sse_customer_key": null,
            "sts_endpoint": null,
            "token": null,
            "workspace_key_prefix": null
        },
        "hash": 704415183
    },
    "modules": [
        {
            "path": [
                "root"
            ],
            "outputs": {},
            "resources": {},
            "depends_on": []
        }
    ]
}
```

We notice our config values in this file, like the remote state bucket to use, the key within that bucket, encryption enabled, etc. This file is essentially a connection point or pointer in our local project so that terraform knows how to use and communicate with the remote storage. `terraform init` being the thing managing all of this for us so that other commands can work with the configured state appropriately.

Last thing to note here, is that init doesn't actually do anything in the remote state bucket aside ensuring that it actually exists. Nothing is created there by init itself, it just sets up this local pointer so that further commands can find and set up the state location resources.

### The `-plugin-dir` argument

We've already seen how `terraform init` can automatically download and stage provider plugins for use in our local project `.terraform` directory. There's a particularly helpful argument to `init` that can help in situations where we might want to pre-download any plugins that terraform needs. A good use-case would be air-gapped environments running terraform operations. Let's mimic this scenario.

By default, terraform will look in the following locations for any pre-downloaded plugins:

* `~/.terraform.d/plugins` on \*nix
* `~\AppData\Roaming\terraform.d\plugins` on Windows

By default, if not found there or already downloaded in a project's `.terraform` directory, it'll find and download the plugin. If you use `-plugin-dir` though, you're basically telling terraform that a required version _must_ be in this location, and that it should never attempt a download. So, let's use a custom location, so we'll "pre-download" our aws provider plugin and then point init at this location

```
$ mkdir -p custom-plugin-dir
$ cp $(find .terraform -name terraform-provider-aws*) ./custom-plugin-dir/
```

Next, let's delete our .terraform directory to start fresh

```
$ rm -rf .terraform
```

Now, let's run init again pointing at our custom plugin directory with pre-downloaded plugins:

```
$ terraform init -plugin-dir=./custom-plugin-dir -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
```

And we'll have an updated look at our `.terraform` directory and its contents:

```
.terraform/
├── plugin_path
├── plugins
│   └── linux_amd64
│       └── lock.json
└── terraform.tfstate
```

Notice that we no longer have an actual plugin file in our plugins directory here. The `.terraform/plugin_path` instead points terraform to a local location where it can find the provider plugin to use:

```
$ cat .terraform/plugin_path
[
  "./custom-plugin-dir"
]
```

That'll do for this exercise. You should know just about everything there is to know about `terraform init` now. I encourage you to continue to look at the docs and CLI help for `init` as you move forward in your Terraform journey.
