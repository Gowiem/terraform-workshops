# Exercise 8: Debugging Terraform

We'll use this exercise to get a chance to see `TF_LOG` and `TF_LOG_PATH` in action

Let's start by running `terraform init` with the normal, default verbosity level, so without `TF_LOG` set:

```
$ terraform init

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Pretty simple and familiar. Let's try one of the others settings for `TF_LOG`: `ERROR`:

```
$ TF_LOG=ERROR terraform init
2020/08/09 17:27:05 [WARN] Log levels other than TRACE are currently unreliable, and are supported only for backward compatibility.
  Use TF_LOG=TRACE to see Terraform's internal logs.
  ----

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Interesting, so the current state of Terraform is telling us that anything other than `TRACE` or `TF_LOG` remaining unset would be unreliable. Presumably Hashicorp still has more work to do in this area. We should reliably have the ability to use `TRACE` though, so let's see what that looks like

```
$ TF_LOG=TRACE terraform init
2020/08/09 17:28:32 [INFO] Terraform version: 0.12.29
2020/08/09 17:28:32 [INFO] Go runtime version: go1.12.13
2020/08/09 17:28:32 [INFO] CLI args: []string{"/Users/gowiem/.tfenv/versions/0.12.29/terraform", "init"}
2020/08/09 17:28:32 [DEBUG] Attempting to open CLI config file: /Users/gowiem/.terraformrc
2020/08/09 17:28:32 [DEBUG] File doesn't exist, but doesn't need to. Ignoring.
2020/08/09 17:28:32 [INFO] CLI command args: []string{"init"}

Initializing the backend...
2020/08/09 17:28:32 [TRACE] Meta.Backend: no config given or present on disk, so returning nil config
2020/08/09 17:28:32 [TRACE] Meta.Backend: backend has not previously been initialized in this working directory
2020/08/09 17:28:32 [DEBUG] New state was assigned lineage "4e63994d-1681-fa72-70b3-7c5af6faae94"
2020/08/09 17:28:32 [TRACE] Meta.Backend: using default local state only (no backend configuration, and no existing initialized backend)
2020/08/09 17:28:32 [TRACE] Meta.Backend: instantiated backend of type <nil>
2020/08/09 17:28:32 [DEBUG] checking for provider in "."
2020/08/09 17:28:32 [DEBUG] checking for provider in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:28:32 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:28:32 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:28:32 [DEBUG] found valid plugin: "aws", "2.70.0", "/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:28:32 [DEBUG] checking for provisioner in "."
2020/08/09 17:28:32 [DEBUG] checking for provisioner in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:28:32 [DEBUG] checking for provisioner in ".terraform/plugins/darwin_amd64"
2020/08/09 17:28:32 [TRACE] Meta.Backend: backend <nil> does not support operations, so wrapping it in a local backend
2020/08/09 17:28:32 [TRACE] backend/local: state manager for workspace "default" will:
 - read initial snapshot from terraform.tfstate
 - write new snapshots to terraform.tfstate
 - create any backup at terraform.tfstate.backup
2020/08/09 17:28:32 [TRACE] statemgr.Filesystem: reading initial snapshot from terraform.tfstate
2020/08/09 17:28:32 [TRACE] statemgr.Filesystem: snapshot file has nil snapshot, but that's okay
2020/08/09 17:28:32 [TRACE] statemgr.Filesystem: read nil snapshot
2020/08/09 17:28:32 [DEBUG] checking for provider in "."
2020/08/09 17:28:32 [DEBUG] checking for provider in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:28:32 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:28:32 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:28:32 [DEBUG] found valid plugin: "aws", "2.70.0", "/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4"

2020/08/09 17:28:32 [DEBUG] plugin requirements: "aws"="~> 2.0"
2020/08/09 17:28:32 [DEBUG] checking for provider in "."
Initializing provider plugins...
2020/08/09 17:28:32 [DEBUG] checking for provider in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:28:32 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:28:32 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:28:32 [DEBUG] found valid plugin: "aws", "2.70.0", "/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:28:32 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:28:32 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Wow, so we get quite a bit more info on this run, telling us a lot about what Terraform is doing under the hood over the course of executing the init.

First, note the log levels available on each line. So, the following would be info I'd only get when running with `TRACE`:

```
2020/08/09 17:28:32 [TRACE] backend/local: state manager for workspace "default" will:
 - read initial snapshot from terraform.tfstate
 - write new snapshots to terraform.tfstate
 - create any backup at terraform.tfstate.backup
```

Let's step through the whole thing though and pick out some particularly noteworthy lines

```
2020/08/09 17:28:32 [DEBUG] Attempting to open CLI config file: /Users/gowiem/.terraformrc
```

Ah, so Terraform has the concept of a local CLI config file. We've not covered that in this course, nor will we, but even looking deeper into logs this way can be a good source of learning.

```
2020/08/09 17:28:32 [TRACE] Meta.Backend: using default local state only (no backend configuration, and no existing initialized backend)
```

We are indeed using a local state configuration in this exercise, no remote state backend. We get some more info about `init` setting up state and awareness, and remote state backend should we have our project configured to use a remote backend.

```
2020/08/09 17:28:32 [DEBUG] checking for provider in "."
2020/08/09 17:28:32 [DEBUG] checking for provider in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:28:32 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:28:32 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:28:32 [DEBUG] found valid plugin: "aws", "2.70.0", "/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4"
```

This sort of info gives us more visibility into what Terraform is doing to identify providers defined in code, and find the provider plugin locally if it can, otherwise download it.

Let's use this same approach to help us see more about an error. Let's have a look at our `main.tf`

```
provider "aws" {
  version = "~> 2.0"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_invalid_resource_type" "name" {
  id = "${var.student_alias}-01"
}
```

Syntactically all seems OK. But, we're going to attempt to create a resource that isn't defined or available in our AWS provider. Of the 4 error types we discussed, what type of error do you think this should produce?

Let's see the error first without default log verbosity:

```
$ terraform plan
Error: Invalid resource type

  on main.tf line 9, in resource "aws_invalid_resource_type" "name":
   9: resource "aws_invalid_resource_type" "name" {

The provider provider.aws does not support resource type
"aws_invalid_resource_type".
```

Next, let's just revisit `terraform validate`. It's another root subcommand of the Terraform CLI and gives us the ability to validate our code in isolation from other commands. We talked about `terraform init` being able to do some syntax checking. `terraform validate` goes one step further to make sure that things like our resource definitions are valid:

```
$ terraform validate
Error: Invalid resource type

  on main.tf line 9, in resource "aws_invalid_resource_type" "name":
   9: resource "aws_invalid_resource_type" "name" {

The provider provider.aws does not support resource type
"aws_invalid_resource_type".
```

The exact same output we got from plan. This suggests that plan also runs just what `terraform validate` does, and this is indeed true. The separation of this validation into a separate command can be useful in certain workflows, especially automated ones that are focused on failing fast and with distinct gates or stages.

Whether it comes from `validate` or `plan`, helpful output even with this log level, should be pretty easy for us to identify the problem in this simple example scenario, but of course the context won't always be this clear. So, let's turn on `TRACE` logging and see what we can see

```
$ TF_LOG=TRACE terraform plan
2020/08/09 17:45:37 [INFO] Terraform version: 0.12.29
2020/08/09 17:45:37 [INFO] Go runtime version: go1.12.13
2020/08/09 17:45:37 [INFO] CLI args: []string{"/Users/gowiem/.tfenv/versions/0.12.29/terraform", "plan"}
2020/08/09 17:45:37 [DEBUG] Attempting to open CLI config file: /Users/gowiem/.terraformrc
2020/08/09 17:45:37 [DEBUG] File doesn't exist, but doesn't need to. Ignoring.
2020/08/09 17:45:37 [INFO] CLI command args: []string{"plan"}
2020/08/09 17:45:37 [TRACE] Meta.Backend: no config given or present on disk, so returning nil config
2020/08/09 17:45:37 [TRACE] Meta.Backend: backend has not previously been initialized in this working directory
2020/08/09 17:45:37 [DEBUG] New state was assigned lineage "f967ff41-ce06-a4b2-eb1c-d6e6dfdb4572"
2020/08/09 17:45:37 [TRACE] Meta.Backend: using default local state only (no backend configuration, and no existing initialized backend)
2020/08/09 17:45:37 [TRACE] Meta.Backend: instantiated backend of type <nil>
2020/08/09 17:45:37 [DEBUG] checking for provider in "."
2020/08/09 17:45:37 [DEBUG] checking for provider in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:45:37 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:45:37 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:45:37 [DEBUG] found valid plugin: "aws", "2.70.0", "/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:45:37 [DEBUG] checking for provisioner in "."
2020/08/09 17:45:37 [DEBUG] checking for provisioner in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:45:37 [DEBUG] checking for provisioner in ".terraform/plugins/darwin_amd64"
2020/08/09 17:45:37 [TRACE] Meta.Backend: backend <nil> does not support operations, so wrapping it in a local backend
2020/08/09 17:45:37 [INFO] backend/local: starting Plan operation
2020/08/09 17:45:37 [TRACE] backend/local: requesting state manager for workspace "default"
2020/08/09 17:45:37 [TRACE] backend/local: state manager for workspace "default" will:
 - read initial snapshot from terraform.tfstate
 - write new snapshots to terraform.tfstate
 - create any backup at terraform.tfstate.backup
2020/08/09 17:45:37 [TRACE] backend/local: requesting state lock for workspace "default"
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: preparing to manage state snapshots at terraform.tfstate
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: no previously-stored snapshot exists
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: locking terraform.tfstate using fcntl flock
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: writing lock metadata to .terraform.tfstate.lock.info
2020/08/09 17:45:37 [TRACE] backend/local: reading remote state for workspace "default"
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: reading latest snapshot from terraform.tfstate
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: snapshot file has nil snapshot, but that's okay
2020/08/09 17:45:37 [TRACE] statemgr.Filesystem: read nil snapshot
2020/08/09 17:45:37 [TRACE] backend/local: retrieving local state snapshot for workspace "default"
2020/08/09 17:45:37 [TRACE] backend/local: building context for current working directory
2020/08/09 17:45:37 [TRACE] terraform.NewContext: starting
2020/08/09 17:45:37 [TRACE] terraform.NewContext: resolving provider version selections
2020/08/09 17:45:38 [TRACE] terraform.NewContext: loading provider schemas
2020/08/09 17:45:38 [TRACE] LoadSchemas: retrieving schema for provider type "aws"
2020-08-09T17:45:38.101-0600 [INFO]  plugin: configuring client automatic mTLS
2020-08-09T17:45:38.127-0600 [DEBUG] plugin: starting plugin: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 args=[/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4]
2020-08-09T17:45:38.137-0600 [DEBUG] plugin: plugin started: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76409
2020-08-09T17:45:38.137-0600 [DEBUG] plugin: waiting for RPC address: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4
2020-08-09T17:45:38.164-0600 [INFO]  plugin.terraform-provider-aws_v2.70.0_x4: configuring server automatic mTLS: timestamp=2020-08-09T17:45:38.164-0600
2020-08-09T17:45:38.191-0600 [DEBUG] plugin: using plugin: version=5
2020-08-09T17:45:38.191-0600 [DEBUG] plugin.terraform-provider-aws_v2.70.0_x4: plugin address: address=/var/folders/sq/xw253p5n2xb8bp0ngz5nr_080000gn/T/plugin379322044 network=unix timestamp=2020-08-09T17:45:38.191-0600
2020/08/09 17:45:38 [TRACE] GRPCProvider: GetSchema
2020-08-09T17:45:38.247-0600 [TRACE] plugin.stdio: waiting for stdio data
2020/08/09 17:45:38 [TRACE] GRPCProvider: Close
2020-08-09T17:45:38.311-0600 [WARN]  plugin.stdio: received EOF, stopping recv loop: err="rpc error: code = Unavailable desc = transport is closing"
2020-08-09T17:45:38.314-0600 [DEBUG] plugin: plugin process exited: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76409
2020-08-09T17:45:38.314-0600 [DEBUG] plugin: plugin exited
2020/08/09 17:45:38 [TRACE] terraform.NewContext: complete
2020/08/09 17:45:38 [TRACE] backend/local: finished building terraform.Context
2020/08/09 17:45:38 [TRACE] backend/local: requesting interactive input, if necessary
2020/08/09 17:45:38 [TRACE] Context.Input: Prompting for provider arguments
2020/08/09 17:45:38 [TRACE] Context.Input: Provider provider.aws declared at main.tf:1,1-15
2020/08/09 17:45:38 [TRACE] Context.Input: Input for provider.aws: map[string]cty.Value{}
2020/08/09 17:45:38 [TRACE] backend/local: running validation operation
2020/08/09 17:45:38 [INFO] terraform: building graph: GraphTypeValidate
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.ConfigTransformer
2020/08/09 17:45:38 [TRACE] ConfigTransformer: Starting for path:
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.ConfigTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
  data.aws_vpc.default - *terraform.NodeValidatableResource
  ------
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.LocalTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.LocalTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.OutputTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.OutputTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.OrphanResourceInstanceTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.OrphanResourceInstanceTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.StateTransformer
2020/08/09 17:45:38 [TRACE] StateTransformer: state is empty, so nothing to do
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.StateTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.OrphanOutputTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.OrphanOutputTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.AttachResourceConfigTransformer
2020/08/09 17:45:38 [TRACE] AttachResourceConfigTransformer: attaching to "aws_invalid_resource_type.name" (*terraform.NodeValidatableResource) config from main.tf:9,1-44
2020/08/09 17:45:38 [TRACE] AttachResourceConfigTransformer: attaching to "data.aws_vpc.default" (*terraform.NodeValidatableResource) config from hcl.Range{Filename:"main.tf", Start:hcl.Pos{Line:5, Column:1, Byte:41}, End:hcl.Pos{Line:5, Column:25, Byte:65}}
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.AttachResourceConfigTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.AttachStateTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.AttachStateTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.RootVariableTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.RootVariableTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.MissingProvisionerTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.MissingProvisionerTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.ProvisionerTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.ProvisionerTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.ModuleVariableTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.ModuleVariableTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.graphTransformerMulti
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.ProviderConfigTransformer
2020/08/09 17:45:38 [TRACE] ProviderConfigTransformer: attaching to "provider.aws" provider configuration from main.tf:1,1-15
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.ProviderConfigTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
  data.aws_vpc.default - *terraform.NodeValidatableResource
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.MissingProviderTransformer
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.MissingProviderTransformer (no changes)
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.ProviderTransformer
2020/08/09 17:45:38 [TRACE] ProviderTransformer: aws_invalid_resource_type.name is provided by provider.aws or inherited equivalent
2020/08/09 17:45:38 [TRACE] ProviderTransformer: data.aws_vpc.default is provided by provider.aws or inherited equivalent
2020/08/09 17:45:38 [TRACE] ProviderTransformer: exact match for provider.aws serving aws_invalid_resource_type.name
2020/08/09 17:45:38 [DEBUG] ProviderTransformer: "aws_invalid_resource_type.name" (*terraform.NodeValidatableResource) needs provider.aws
2020/08/09 17:45:38 [TRACE] ProviderTransformer: exact match for provider.aws serving data.aws_vpc.default
2020/08/09 17:45:38 [DEBUG] ProviderTransformer: "data.aws_vpc.default" (*terraform.NodeValidatableResource) needs provider.aws
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.ProviderTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.PruneProviderTransformer
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.PruneProviderTransformer (no changes)
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.ParentProviderTransformer
2020/08/09 17:45:38 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.ParentProviderTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.graphTransformerMulti with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.RemovedModuleTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.RemovedModuleTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.AttachSchemaTransformer
2020/08/09 17:45:38 [ERROR] AttachSchemaTransformer: No resource schema available for aws_invalid_resource_type.name
2020/08/09 17:45:38 [TRACE] AttachSchemaTransformer: attaching resource schema to data.aws_vpc.default
2020/08/09 17:45:38 [TRACE] AttachSchemaTransformer: attaching provider config schema to provider.aws
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.AttachSchemaTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.ReferenceTransformer
2020/08/09 17:45:38 [WARN] no schema is attached to aws_invalid_resource_type.name, so config references cannot be detected
2020/08/09 17:45:38 [WARN] no schema is attached to aws_invalid_resource_type.name, so config references cannot be detected
2020/08/09 17:45:38 [DEBUG] ReferenceTransformer: "aws_invalid_resource_type.name" references: []
2020/08/09 17:45:38 [DEBUG] ReferenceTransformer: "data.aws_vpc.default" references: []
2020/08/09 17:45:38 [DEBUG] ReferenceTransformer: "provider.aws" references: []
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.ReferenceTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.CountBoundaryTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.CountBoundaryTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.TargetsTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.TargetsTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.ForcedCBDTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.ForcedCBDTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.CloseProviderTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.CloseProviderTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  provider.aws (close) - *terraform.graphNodeCloseProvider
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.CloseProvisionerTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.CloseProvisionerTransformer (no changes)
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.RootTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.RootTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  provider.aws (close) - *terraform.graphNodeCloseProvider
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  root - terraform.graphNodeRoot
    meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    provider.aws (close) - *terraform.graphNodeCloseProvider
  ------
2020/08/09 17:45:38 [TRACE] Executing graph transform *terraform.TransitiveReductionTransformer
2020/08/09 17:45:38 [TRACE] Completed graph transform *terraform.TransitiveReductionTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
  provider.aws - *terraform.NodeApplyableProvider
  provider.aws (close) - *terraform.graphNodeCloseProvider
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
  root - terraform.graphNodeRoot
    meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    provider.aws (close) - *terraform.graphNodeCloseProvider
  ------
2020/08/09 17:45:38 [DEBUG] Starting graph walk: walkValidate
2020/08/09 17:45:38 [TRACE] dag/walk: updating graph
2020/08/09 17:45:38 [TRACE] dag/walk: added new vertex: "data.aws_vpc.default"
2020/08/09 17:45:38 [TRACE] dag/walk: added new vertex: "provider.aws"
2020/08/09 17:45:38 [TRACE] dag/walk: added new vertex: "meta.count-boundary (EachMode fixup)"
2020/08/09 17:45:38 [TRACE] dag/walk: added new vertex: "provider.aws (close)"
2020/08/09 17:45:38 [TRACE] dag/walk: added new vertex: "root"
2020/08/09 17:45:38 [TRACE] dag/walk: added new vertex: "aws_invalid_resource_type.name"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "root" waiting on "meta.count-boundary (EachMode fixup)"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "root" waiting on "provider.aws (close)"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "aws_invalid_resource_type.name" waiting on "provider.aws"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "meta.count-boundary (EachMode fixup)" waiting on "data.aws_vpc.default"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "data.aws_vpc.default" waiting on "provider.aws"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "meta.count-boundary (EachMode fixup)" waiting on "aws_invalid_resource_type.name"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "provider.aws (close)" waiting on "aws_invalid_resource_type.name"
2020/08/09 17:45:38 [TRACE] dag/walk: added edge: "provider.aws (close)" waiting on "data.aws_vpc.default"
2020/08/09 17:45:38 [TRACE] dag/walk: dependencies changed for "meta.count-boundary (EachMode fixup)", sending new deps
2020/08/09 17:45:38 [TRACE] dag/walk: dependencies changed for "data.aws_vpc.default", sending new deps
2020/08/09 17:45:38 [TRACE] dag/walk: dependencies changed for "provider.aws (close)", sending new deps
2020/08/09 17:45:38 [TRACE] dag/walk: dependencies changed for "root", sending new deps
2020/08/09 17:45:38 [TRACE] dag/walk: dependencies changed for "aws_invalid_resource_type.name", sending new deps
2020/08/09 17:45:38 [TRACE] dag/walk: visiting "provider.aws"
2020/08/09 17:45:38 [TRACE] vertex "provider.aws": starting visit (*terraform.NodeApplyableProvider)
2020/08/09 17:45:38 [TRACE] vertex "provider.aws": evaluating
2020/08/09 17:45:38 [TRACE] [walkValidate] Entering eval tree: provider.aws
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalInitProvider
2020-08-09T17:45:38.315-0600 [INFO]  plugin: configuring client automatic mTLS
2020-08-09T17:45:38.340-0600 [DEBUG] plugin: starting plugin: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 args=[/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4]
2020-08-09T17:45:38.352-0600 [DEBUG] plugin: plugin started: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76410
2020-08-09T17:45:38.352-0600 [DEBUG] plugin: waiting for RPC address: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4
2020-08-09T17:45:38.380-0600 [INFO]  plugin.terraform-provider-aws_v2.70.0_x4: configuring server automatic mTLS: timestamp=2020-08-09T17:45:38.378-0600
2020-08-09T17:45:38.407-0600 [DEBUG] plugin: using plugin: version=5
2020-08-09T17:45:38.407-0600 [DEBUG] plugin.terraform-provider-aws_v2.70.0_x4: plugin address: address=/var/folders/sq/xw253p5n2xb8bp0ngz5nr_080000gn/T/plugin150846913 network=unix timestamp=2020-08-09T17:45:38.407-0600
2020/08/09 17:45:38 [TRACE] BuiltinEvalContext: Initialized "aws" provider for provider.aws
2020/08/09 17:45:38 [TRACE] <root>: eval: terraform.EvalNoop
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalOpFilter
2020-08-09T17:45:38.461-0600 [TRACE] plugin.stdio: waiting for stdio data
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalGetProvider
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalValidateProvider
2020/08/09 17:45:38 [TRACE] buildProviderConfig for provider.aws: using explicit config only
2020/08/09 17:45:38 [TRACE] GRPCProvider: GetSchema
2020/08/09 17:45:38 [TRACE] GRPCProvider: PrepareProviderConfig
2020/08/09 17:45:38 [TRACE] <root>: eval: terraform.EvalNoop
2020/08/09 17:45:38 [TRACE] <root>: eval: terraform.EvalNoop
2020/08/09 17:45:38 [TRACE] [walkValidate] Exiting eval tree: provider.aws
2020/08/09 17:45:38 [TRACE] vertex "provider.aws": visit complete
2020/08/09 17:45:38 [TRACE] dag/walk: visiting "data.aws_vpc.default"
2020/08/09 17:45:38 [TRACE] vertex "data.aws_vpc.default": starting visit (*terraform.NodeValidatableResource)
2020/08/09 17:45:38 [TRACE] dag/walk: visiting "aws_invalid_resource_type.name"
2020/08/09 17:45:38 [TRACE] vertex "data.aws_vpc.default": evaluating
2020/08/09 17:45:38 [TRACE] vertex "aws_invalid_resource_type.name": starting visit (*terraform.NodeValidatableResource)
2020/08/09 17:45:38 [TRACE] vertex "aws_invalid_resource_type.name": evaluating
2020/08/09 17:45:38 [TRACE] [walkValidate] Entering eval tree: aws_invalid_resource_type.name
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalGetProvider
2020/08/09 17:45:38 [TRACE] [walkValidate] Entering eval tree: data.aws_vpc.default
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalGetProvider
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalValidateResource
2020/08/09 17:45:38 [TRACE] <root>: eval: *terraform.EvalValidateResource
2020/08/09 17:45:38 [ERROR] <root>: eval: *terraform.EvalValidateResource, err: Invalid resource type: The provider provider.aws does not support resource type "aws_invalid_resource_type".
2020/08/09 17:45:38 [ERROR] <root>: eval: *terraform.EvalSequence, err: Invalid resource type: The provider provider.aws does not support resource type "aws_invalid_resource_type".
2020/08/09 17:45:38 [TRACE] [walkValidate] Exiting eval tree: aws_invalid_resource_type.name
2020/08/09 17:45:38 [TRACE] vertex "aws_invalid_resource_type.name": visit complete
2020/08/09 17:45:38 [TRACE] GRPCProvider: ValidateDataSourceConfig
2020/08/09 17:45:38 [TRACE] [walkValidate] Exiting eval tree: data.aws_vpc.default
2020/08/09 17:45:38 [TRACE] vertex "data.aws_vpc.default": visit complete
2020/08/09 17:45:38 [TRACE] dag/walk: upstream of "meta.count-boundary (EachMode fixup)" errored, so skipping
2020/08/09 17:45:38 [TRACE] dag/walk: upstream of "provider.aws (close)" errored, so skipping
2020/08/09 17:45:38 [TRACE] dag/walk: upstream of "root" errored, so skipping
2020/08/09 17:45:38 [TRACE] statemgr.Filesystem: removing lock metadata file .terraform.tfstate.lock.info

2020/08/09 17:45:38 [TRACE] statemgr.Filesystem: unlocking terraform.tfstate using fcntl flock
Error: Invalid resource type

  on main.tf line 9, in resource "aws_invalid_resource_type" "name":
   9: resource "aws_invalid_resource_type" "name" {

The provider provider.aws does not support resource type
"aws_invalid_resource_type".

2020-08-09T17:45:38.593-0600 [WARN]  plugin.stdio: received EOF, stopping recv loop: err="rpc error: code = Unavailable desc = transport is closing"
2020-08-09T17:45:38.596-0600 [DEBUG] plugin: plugin process exited: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76410
2020-08-09T17:45:38.596-0600 [DEBUG] plugin: plugin exited
```

OK, wow, there's a lot of stuff here. I'm not sure we'd actually need everything from `TRACE` and maybe, despite others being unreliable, maybe we'd only want to use `DEBUG` in this case or maybe even `ERROR`. Nonetheless, let's parse the highly verbose output above and see what we can glean.

```
2020/08/09 17:45:38 [ERROR] <root>: eval: *terraform.EvalValidateResource, err: Invalid resource type: The provider provider.aws does not support resource type "aws_invalid_resource_type".
2020/08/09 17:45:38 [ERROR] <root>: eval: *terraform.EvalSequence, err: Invalid resource type: The provider provider.aws does not support resource type "aws_invalid_resource_type".
```

So, we can see some internal Terraform error log lines that say just a bit more on the error topic. Internally, this is how Terraform will tell us more about certain error cases. If the normal log output doesn't give us the full picture, this should and provide more guidance on tracking down the underlying problem.

Last piece for this exercise is to use `TF_LOG_PATH`. Let's do the same trace we did with plan, but we'll set `TF_LOG_PATH` to output our verbose log to a file called `plan.log`

```
$ TF_LOG=TRACE TF_LOG_PATH=./plan.log terraform plan
Error: Invalid resource type

  on main.tf line 9, in resource "aws_invalid_resource_type" "name":
   9: resource "aws_invalid_resource_type" "name" {

The provider provider.aws does not support resource type
"aws_invalid_resource_type".
```

Ah, so our console output looks just like it would if we weren't using `TF_LOG` at all. Looking out our `plan.log` file now:

```
2020/08/09 17:50:24 [INFO] Terraform version: 0.12.29
2020/08/09 17:50:24 [INFO] Go runtime version: go1.12.13
2020/08/09 17:50:24 [INFO] CLI args: []string{"/Users/gowiem/.tfenv/versions/0.12.29/terraform", "plan"}
2020/08/09 17:50:24 [DEBUG] Attempting to open CLI config file: /Users/gowiem/.terraformrc
2020/08/09 17:50:24 [DEBUG] File doesn't exist, but doesn't need to. Ignoring.
2020/08/09 17:50:24 [INFO] CLI command args: []string{"plan"}
2020/08/09 17:50:24 [TRACE] Meta.Backend: no config given or present on disk, so returning nil config
2020/08/09 17:50:24 [TRACE] Meta.Backend: backend has not previously been initialized in this working directory
2020/08/09 17:50:24 [DEBUG] New state was assigned lineage "22160491-e8e1-d0d2-23e4-f8aea9e35537"
2020/08/09 17:50:24 [TRACE] Meta.Backend: using default local state only (no backend configuration, and no existing initialized backend)
2020/08/09 17:50:24 [TRACE] Meta.Backend: instantiated backend of type <nil>
2020/08/09 17:50:24 [DEBUG] checking for provider in "."
2020/08/09 17:50:24 [DEBUG] checking for provider in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:50:24 [DEBUG] checking for provider in ".terraform/plugins/darwin_amd64"
2020/08/09 17:50:24 [DEBUG] found provider "terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:50:24 [DEBUG] found valid plugin: "aws", "2.70.0", "/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4"
2020/08/09 17:50:24 [DEBUG] checking for provisioner in "."
2020/08/09 17:50:24 [DEBUG] checking for provisioner in "/Users/gowiem/.tfenv/versions/0.12.29"
2020/08/09 17:50:24 [DEBUG] checking for provisioner in ".terraform/plugins/darwin_amd64"
2020/08/09 17:50:24 [TRACE] Meta.Backend: backend <nil> does not support operations, so wrapping it in a local backend
2020/08/09 17:50:24 [INFO] backend/local: starting Plan operation
2020/08/09 17:50:24 [TRACE] backend/local: requesting state manager for workspace "default"
2020/08/09 17:50:24 [TRACE] backend/local: state manager for workspace "default" will:
 - read initial snapshot from terraform.tfstate
 - write new snapshots to terraform.tfstate
 - create any backup at terraform.tfstate.backup
2020/08/09 17:50:24 [TRACE] backend/local: requesting state lock for workspace "default"
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: preparing to manage state snapshots at terraform.tfstate
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: no previously-stored snapshot exists
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: locking terraform.tfstate using fcntl flock
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: writing lock metadata to .terraform.tfstate.lock.info
2020/08/09 17:50:24 [TRACE] backend/local: reading remote state for workspace "default"
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: reading latest snapshot from terraform.tfstate
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: snapshot file has nil snapshot, but that's okay
2020/08/09 17:50:24 [TRACE] statemgr.Filesystem: read nil snapshot
2020/08/09 17:50:24 [TRACE] backend/local: retrieving local state snapshot for workspace "default"
2020/08/09 17:50:24 [TRACE] backend/local: building context for current working directory
2020/08/09 17:50:24 [TRACE] terraform.NewContext: starting
2020/08/09 17:50:24 [TRACE] terraform.NewContext: resolving provider version selections
2020/08/09 17:50:24 [TRACE] terraform.NewContext: loading provider schemas
2020/08/09 17:50:24 [TRACE] LoadSchemas: retrieving schema for provider type "aws"
2020-08-09T17:50:24.902-0600 [INFO]  plugin: configuring client automatic mTLS
2020-08-09T17:50:24.929-0600 [DEBUG] plugin: starting plugin: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 args=[/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4]
2020-08-09T17:50:24.939-0600 [DEBUG] plugin: plugin started: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76817
2020-08-09T17:50:24.939-0600 [DEBUG] plugin: waiting for RPC address: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4
2020-08-09T17:50:24.965-0600 [INFO]  plugin.terraform-provider-aws_v2.70.0_x4: configuring server automatic mTLS: timestamp=2020-08-09T17:50:24.965-0600
2020-08-09T17:50:24.993-0600 [DEBUG] plugin: using plugin: version=5
2020-08-09T17:50:24.993-0600 [DEBUG] plugin.terraform-provider-aws_v2.70.0_x4: plugin address: address=/var/folders/sq/xw253p5n2xb8bp0ngz5nr_080000gn/T/plugin616275180 network=unix timestamp=2020-08-09T17:50:24.993-0600
2020/08/09 17:50:25 [TRACE] GRPCProvider: GetSchema
2020-08-09T17:50:25.047-0600 [TRACE] plugin.stdio: waiting for stdio data
2020/08/09 17:50:25 [TRACE] GRPCProvider: Close
2020-08-09T17:50:25.112-0600 [WARN]  plugin.stdio: received EOF, stopping recv loop: err="rpc error: code = Unavailable desc = transport is closing"
2020-08-09T17:50:25.115-0600 [DEBUG] plugin: plugin process exited: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76817
2020-08-09T17:50:25.115-0600 [DEBUG] plugin: plugin exited
2020/08/09 17:50:25 [TRACE] terraform.NewContext: complete
2020/08/09 17:50:25 [TRACE] backend/local: finished building terraform.Context
2020/08/09 17:50:25 [TRACE] backend/local: requesting interactive input, if necessary
2020/08/09 17:50:25 [TRACE] Context.Input: Prompting for provider arguments
2020/08/09 17:50:25 [TRACE] Context.Input: Provider provider.aws declared at main.tf:1,1-15
2020/08/09 17:50:25 [TRACE] Context.Input: Input for provider.aws: map[string]cty.Value{}
2020/08/09 17:50:25 [TRACE] backend/local: running validation operation
2020/08/09 17:50:25 [INFO] terraform: building graph: GraphTypeValidate
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.ConfigTransformer
2020/08/09 17:50:25 [TRACE] ConfigTransformer: Starting for path:
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.ConfigTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
  data.aws_vpc.default - *terraform.NodeValidatableResource
  ------
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.LocalTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.LocalTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.OutputTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.OutputTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.OrphanResourceInstanceTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.OrphanResourceInstanceTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.StateTransformer
2020/08/09 17:50:25 [TRACE] StateTransformer: state is empty, so nothing to do
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.StateTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.OrphanOutputTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.OrphanOutputTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.AttachResourceConfigTransformer
2020/08/09 17:50:25 [TRACE] AttachResourceConfigTransformer: attaching to "aws_invalid_resource_type.name" (*terraform.NodeValidatableResource) config from main.tf:9,1-44
2020/08/09 17:50:25 [TRACE] AttachResourceConfigTransformer: attaching to "data.aws_vpc.default" (*terraform.NodeValidatableResource) config from hcl.Range{Filename:"main.tf", Start:hcl.Pos{Line:5, Column:1, Byte:41}, End:hcl.Pos{Line:5, Column:25, Byte:65}}
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.AttachResourceConfigTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.AttachStateTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.AttachStateTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.RootVariableTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.RootVariableTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.MissingProvisionerTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.MissingProvisionerTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.ProvisionerTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.ProvisionerTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.ModuleVariableTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.ModuleVariableTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.graphTransformerMulti
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.ProviderConfigTransformer
2020/08/09 17:50:25 [TRACE] ProviderConfigTransformer: attaching to "provider.aws" provider configuration from main.tf:1,1-15
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.ProviderConfigTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
  data.aws_vpc.default - *terraform.NodeValidatableResource
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.MissingProviderTransformer
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.MissingProviderTransformer (no changes)
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.ProviderTransformer
2020/08/09 17:50:25 [TRACE] ProviderTransformer: aws_invalid_resource_type.name is provided by provider.aws or inherited equivalent
2020/08/09 17:50:25 [TRACE] ProviderTransformer: data.aws_vpc.default is provided by provider.aws or inherited equivalent
2020/08/09 17:50:25 [TRACE] ProviderTransformer: exact match for provider.aws serving aws_invalid_resource_type.name
2020/08/09 17:50:25 [DEBUG] ProviderTransformer: "aws_invalid_resource_type.name" (*terraform.NodeValidatableResource) needs provider.aws
2020/08/09 17:50:25 [TRACE] ProviderTransformer: exact match for provider.aws serving data.aws_vpc.default
2020/08/09 17:50:25 [DEBUG] ProviderTransformer: "data.aws_vpc.default" (*terraform.NodeValidatableResource) needs provider.aws
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.ProviderTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.PruneProviderTransformer
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.PruneProviderTransformer (no changes)
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Executing graph transform *terraform.ParentProviderTransformer
2020/08/09 17:50:25 [TRACE] (graphTransformerMulti) Completed graph transform *terraform.ParentProviderTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.graphTransformerMulti with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.RemovedModuleTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.RemovedModuleTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.AttachSchemaTransformer
2020/08/09 17:50:25 [TRACE] AttachSchemaTransformer: attaching resource schema to data.aws_vpc.default
2020/08/09 17:50:25 [TRACE] AttachSchemaTransformer: attaching provider config schema to provider.aws
2020/08/09 17:50:25 [ERROR] AttachSchemaTransformer: No resource schema available for aws_invalid_resource_type.name
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.AttachSchemaTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.ReferenceTransformer
2020/08/09 17:50:25 [WARN] no schema is attached to aws_invalid_resource_type.name, so config references cannot be detected
2020/08/09 17:50:25 [WARN] no schema is attached to aws_invalid_resource_type.name, so config references cannot be detected
2020/08/09 17:50:25 [DEBUG] ReferenceTransformer: "aws_invalid_resource_type.name" references: []
2020/08/09 17:50:25 [DEBUG] ReferenceTransformer: "data.aws_vpc.default" references: []
2020/08/09 17:50:25 [DEBUG] ReferenceTransformer: "provider.aws" references: []
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.ReferenceTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.CountBoundaryTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.CountBoundaryTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.TargetsTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.TargetsTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.ForcedCBDTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.ForcedCBDTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.CloseProviderTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.CloseProviderTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  provider.aws (close) - *terraform.graphNodeCloseProvider
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  ------
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.CloseProvisionerTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.CloseProvisionerTransformer (no changes)
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.RootTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.RootTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  provider.aws - *terraform.NodeApplyableProvider
  provider.aws (close) - *terraform.graphNodeCloseProvider
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  root - terraform.graphNodeRoot
    meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    provider.aws (close) - *terraform.graphNodeCloseProvider
  ------
2020/08/09 17:50:25 [TRACE] Executing graph transform *terraform.TransitiveReductionTransformer
2020/08/09 17:50:25 [TRACE] Completed graph transform *terraform.TransitiveReductionTransformer with new graph:
  aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  data.aws_vpc.default - *terraform.NodeValidatableResource
    provider.aws - *terraform.NodeApplyableProvider
  meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
  provider.aws - *terraform.NodeApplyableProvider
  provider.aws (close) - *terraform.graphNodeCloseProvider
    aws_invalid_resource_type.name - *terraform.NodeValidatableResource
    data.aws_vpc.default - *terraform.NodeValidatableResource
  root - terraform.graphNodeRoot
    meta.count-boundary (EachMode fixup) - *terraform.NodeCountBoundary
    provider.aws (close) - *terraform.graphNodeCloseProvider
  ------
2020/08/09 17:50:25 [DEBUG] Starting graph walk: walkValidate
2020/08/09 17:50:25 [TRACE] dag/walk: updating graph
2020/08/09 17:50:25 [TRACE] dag/walk: added new vertex: "provider.aws"
2020/08/09 17:50:25 [TRACE] dag/walk: added new vertex: "meta.count-boundary (EachMode fixup)"
2020/08/09 17:50:25 [TRACE] dag/walk: added new vertex: "provider.aws (close)"
2020/08/09 17:50:25 [TRACE] dag/walk: added new vertex: "root"
2020/08/09 17:50:25 [TRACE] dag/walk: added new vertex: "aws_invalid_resource_type.name"
2020/08/09 17:50:25 [TRACE] dag/walk: added new vertex: "data.aws_vpc.default"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "data.aws_vpc.default" waiting on "provider.aws"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "provider.aws (close)" waiting on "data.aws_vpc.default"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "root" waiting on "meta.count-boundary (EachMode fixup)"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "meta.count-boundary (EachMode fixup)" waiting on "aws_invalid_resource_type.name"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "meta.count-boundary (EachMode fixup)" waiting on "data.aws_vpc.default"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "provider.aws (close)" waiting on "aws_invalid_resource_type.name"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "root" waiting on "provider.aws (close)"
2020/08/09 17:50:25 [TRACE] dag/walk: added edge: "aws_invalid_resource_type.name" waiting on "provider.aws"
2020/08/09 17:50:25 [TRACE] dag/walk: dependencies changed for "data.aws_vpc.default", sending new deps
2020/08/09 17:50:25 [TRACE] dag/walk: dependencies changed for "provider.aws (close)", sending new deps
2020/08/09 17:50:25 [TRACE] dag/walk: dependencies changed for "root", sending new deps
2020/08/09 17:50:25 [TRACE] dag/walk: dependencies changed for "meta.count-boundary (EachMode fixup)", sending new deps
2020/08/09 17:50:25 [TRACE] dag/walk: dependencies changed for "aws_invalid_resource_type.name", sending new deps
2020/08/09 17:50:25 [TRACE] dag/walk: visiting "provider.aws"
2020/08/09 17:50:25 [TRACE] vertex "provider.aws": starting visit (*terraform.NodeApplyableProvider)
2020/08/09 17:50:25 [TRACE] vertex "provider.aws": evaluating
2020/08/09 17:50:25 [TRACE] [walkValidate] Entering eval tree: provider.aws
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalInitProvider
2020-08-09T17:50:25.117-0600 [INFO]  plugin: configuring client automatic mTLS
2020-08-09T17:50:25.142-0600 [DEBUG] plugin: starting plugin: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 args=[/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4]
2020-08-09T17:50:25.156-0600 [DEBUG] plugin: plugin started: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76818
2020-08-09T17:50:25.156-0600 [DEBUG] plugin: waiting for RPC address: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4
2020-08-09T17:50:25.184-0600 [INFO]  plugin.terraform-provider-aws_v2.70.0_x4: configuring server automatic mTLS: timestamp=2020-08-09T17:50:25.183-0600
2020-08-09T17:50:25.212-0600 [DEBUG] plugin: using plugin: version=5
2020-08-09T17:50:25.212-0600 [DEBUG] plugin.terraform-provider-aws_v2.70.0_x4: plugin address: address=/var/folders/sq/xw253p5n2xb8bp0ngz5nr_080000gn/T/plugin150805657 network=unix timestamp=2020-08-09T17:50:25.211-0600
2020/08/09 17:50:25 [TRACE] BuiltinEvalContext: Initialized "aws" provider for provider.aws
2020-08-09T17:50:25.266-0600 [TRACE] plugin.stdio: waiting for stdio data
2020/08/09 17:50:25 [TRACE] <root>: eval: terraform.EvalNoop
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalOpFilter
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalGetProvider
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalValidateProvider
2020/08/09 17:50:25 [TRACE] buildProviderConfig for provider.aws: using explicit config only
2020/08/09 17:50:25 [TRACE] GRPCProvider: GetSchema
2020/08/09 17:50:25 [TRACE] GRPCProvider: PrepareProviderConfig
2020/08/09 17:50:25 [TRACE] <root>: eval: terraform.EvalNoop
2020/08/09 17:50:25 [TRACE] <root>: eval: terraform.EvalNoop
2020/08/09 17:50:25 [TRACE] [walkValidate] Exiting eval tree: provider.aws
2020/08/09 17:50:25 [TRACE] vertex "provider.aws": visit complete
2020/08/09 17:50:25 [TRACE] dag/walk: visiting "data.aws_vpc.default"
2020/08/09 17:50:25 [TRACE] vertex "data.aws_vpc.default": starting visit (*terraform.NodeValidatableResource)
2020/08/09 17:50:25 [TRACE] dag/walk: visiting "aws_invalid_resource_type.name"
2020/08/09 17:50:25 [TRACE] vertex "data.aws_vpc.default": evaluating
2020/08/09 17:50:25 [TRACE] vertex "aws_invalid_resource_type.name": starting visit (*terraform.NodeValidatableResource)
2020/08/09 17:50:25 [TRACE] vertex "aws_invalid_resource_type.name": evaluating
2020/08/09 17:50:25 [TRACE] [walkValidate] Entering eval tree: data.aws_vpc.default
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalGetProvider
2020/08/09 17:50:25 [TRACE] [walkValidate] Entering eval tree: aws_invalid_resource_type.name
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalSequence
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalGetProvider
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalValidateResource
2020/08/09 17:50:25 [TRACE] <root>: eval: *terraform.EvalValidateResource
2020/08/09 17:50:25 [ERROR] <root>: eval: *terraform.EvalValidateResource, err: Invalid resource type: The provider provider.aws does not support resource type "aws_invalid_resource_type".
2020/08/09 17:50:25 [ERROR] <root>: eval: *terraform.EvalSequence, err: Invalid resource type: The provider provider.aws does not support resource type "aws_invalid_resource_type".
2020/08/09 17:50:25 [TRACE] [walkValidate] Exiting eval tree: aws_invalid_resource_type.name
2020/08/09 17:50:25 [TRACE] vertex "aws_invalid_resource_type.name": visit complete
2020/08/09 17:50:25 [TRACE] GRPCProvider: ValidateDataSourceConfig
2020/08/09 17:50:25 [TRACE] [walkValidate] Exiting eval tree: data.aws_vpc.default
2020/08/09 17:50:25 [TRACE] vertex "data.aws_vpc.default": visit complete
2020/08/09 17:50:25 [TRACE] dag/walk: upstream of "provider.aws (close)" errored, so skipping
2020/08/09 17:50:25 [TRACE] dag/walk: upstream of "meta.count-boundary (EachMode fixup)" errored, so skipping
2020/08/09 17:50:25 [TRACE] dag/walk: upstream of "root" errored, so skipping
2020/08/09 17:50:25 [TRACE] statemgr.Filesystem: removing lock metadata file .terraform.tfstate.lock.info
2020/08/09 17:50:25 [TRACE] statemgr.Filesystem: unlocking terraform.tfstate using fcntl flock
2020-08-09T17:50:25.392-0600 [WARN]  plugin.stdio: received EOF, stopping recv loop: err="rpc error: code = Unavailable desc = transport is closing"
2020-08-09T17:50:25.396-0600 [DEBUG] plugin: plugin process exited: path=/Users/gowiem/workspace/terraform-workshops/intermediate-terraform/exercises/08/.terraform/plugins/darwin_amd64/terraform-provider-aws_v2.70.0_x4 pid=76818
2020-08-09T17:50:25.396-0600 [DEBUG] plugin: plugin exited
```

This is a particularly good way for us to separate normal logs from debugging logs. We can see the clear and short default Terraform output from the command itself, and should we need to look deeper we could look into the `TRACE` logs output to a file.

OK, that'll cover debugging topics for intermediate terraform for now. We can move on.
