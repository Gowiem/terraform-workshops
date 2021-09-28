# Exercise #11: Running an Application in AWS using Terraform as Infrastructure Code

We're gonna take a much deeper dive into a more realistic looking Terraform scenario than we have thus far for our
final exercise. This one will be bringing together a number of different things we've talked about over the course of the
last few days. Our goal here is to run an auto-scaled, load-balanced application in AWS and set it all up using
Terraform

## The `microservice` module

Our `microservice` module here is designed to be a generic module for spinning some sort of application that can scale
and be load balanced in AWS. Some key components to this module:

* **AWS Launch Configuration**: a launch configuration defines a standard way in which an EC2 instance should be launched, such as the base AMI, the instance type, the user data (launch script), security groups or firewall rules, etc.
* **AWS Autoscaling Group**: an autoscaling group will use rules and other properties to make decisions on how many of the above launch configurations, or actual servers will be running for our service
* **AWS Application Load Balancer**: a load balancer will listen for the actual user or service requests coming in and decide where these requests should go
	* **Target Group**: a target group is basically the backend of the load balancer, it helps in health checking the autoscaling group to ensure that the load balancer routes appropriately
	* **Listeners**: this is the part that actually listens for requests from the outside, and then directs accordingly to the target group/backend and into the autoscaling group instances
* **user-data directory**: stores the startup scripts for the servers, one for each of a backend server and the frontend server


## The project calling the `microservice` module

```hcl
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE FRONTEND
# ---------------------------------------------------------------------------------------------------------------------

module "frontend" {
  source = "./microservice"

  name                  = "frontend"
  min_size              = 1
  max_size              = 2
  key_name              = var.key_name
  user_data_script      = file("user-data/user-data-frontend.sh")
  server_text           = var.frontend_server_text
  is_internal_alb       = false

  # Pass an output from the backend module to the frontend module. This is the URL of the backend microservice, which
  # the frontend will use for "service calls"
  backend_url = module.backend.url
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BACKEND
# ---------------------------------------------------------------------------------------------------------------------

module "backend" {
  source = "./microservice"

  name                  = "backend"
  min_size              = 1
  max_size              = 3
  key_name              = var.key_name
  user_data_script      = file("user-data/user-data-backend.sh")
  server_text           = var.backend_server_text
  is_internal_alb       = true
}
```

We've abstracted almost everything into our module, and we see here a pretty nice reusability pattern. It also makes it easy
to see our intention for the project overall in the code itself (note: *this* is one of the huge benefits of infrastructure as code that we've talked about):

* We're setting up a backend service that should have at most 3 servers, a minimum of 1 server; we're telling it to use the startup script of `user-data-backend.sh` and we're passing the text that will be served through the service as the output of the app/page
* We're setting up a frontend service that should have at most 2 servers, a minimum of 1 server; it will use the `user-data-frontend.sh` as the startup script and we'll pass the text to serve through the app/page as well

Let's start with init so that we can cover a quick side topic:

```bash
terraform init
```

which should give you output that includes something like:

```
The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to specify version constraints providers via the `terraform` block, with the constraint strings
suggested below.

* provider.template: version = "~> 2.1"
```

We're getting this because our microservice module is using:

```hcl
data "template_file" "user_data" {
  template = "${var.user_data_script}"

  vars = {
    server_text      = "${var.server_text}"
    server_http_port = "${var.server_http_port}"
    backend_url      = "${var.backend_url}"
  }
}
```

this resource is making use of the `template` provider, but our module doesn't define a specific provider block for it, nor
does our terraform using the module, thus we're presented with this message. It's considered best practice to explicitly
define the provider version requirement. Things have been changing fast in terraform and all of
it's available providers, thus locking down to a particular version or at least major version can be helpful if not
necessary in many cases.

So, should the block be defined in the module or the thing using the module? The answer depends, but Hashicorp recommends that
only the _root_ module, or calling Terraform define provider blocks. In this way, those using a module can decide on what
version of the provider they need to use. Modules will inherit provider definitions implicitly by default. See
https://www.terraform.io/docs/language/meta-arguments/module-providers.html for more info.

Let's add an explicit provider version requirement for the `template` provider and re-run init. Add the following to our root `main.tf` file at the top:

```hcl
terraform {
  required_providers {
    template = {
      version = "~> 2.2"
    }
  }
}
```

Then we can re-run init:
```bash
terraform init
```

We should no longer see the warning during init. Let's look at just one other thing here that's related. Say a module does define
a provider with some settings that we don't want. We do have another option to explictly pass a provider to a module by doing
something like:

```hcl
provider "aws" {
  region = "us-east-2"
}

# A non-default, or "aliased" configuration is also defined for a different
# region.
provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

# An example child module is instantiated with the _aliased_ configuration,
# so any AWS resources it defines will use the us-west-2 region.
module "example" {
  source    = "./example"
  providers = {
    aws = "aws.usw2"
  }
}
```

This particular example is defining the default provider for this module or terraform project with a region of us-east-2, but an
alternate provider that can then be passed to the example module.

OK, back to our main exercise though, as soon as you're done with your `init` command, we can move the acutal apply:

```bash
terraform apply
```

**Remember the Exercise 11 AWS Region you were provided along with your username and password? The apply will ask you for a region. Enter that region here**

The apply will present you with the plan and ask you to accept it to continue with the actual apply. Type "yes" and we'll
see the actual creation of resources on AWS start to happen. This will take a little while, so let's look through some other
things in the meantime.

### Some new and common things going on in the `microservice` module

#### Dependencies

```
depends_on = [aws_alb_listener.http]
```

The `depends_on` meta attribute is a common terraform resource property that allows you to define explicit dependencies. In most
cases, Terraform is capable of automatically determining resource dependencies on its own, and thus can make its own internal
decisions about the order of operation. In certain other cases, it's useful to set `depends_on` to resource pointers so you
can instruct Terraform that the items in the list should be created before this resource (or this resource should be destroyed
or updated before the dependent ones)

#### Lifecycle definitions

```
lifecycle {
  create_before_destroy = true
}
```

Lifecycles are another common meta attribute across terraform resources. They define how terraform internally processes changes to the
resource. In this case, we're telling Terraform that if a new resource needs to be created, and one already exists, ensure that
the new resource gets created before the previous one gets destroyed. One major caveat and gotcha of terraform exists in this flow:

**If a resource defines a lifecycle rule of `create_before_destroy = true`, all of the related resource dependencies must also explicitly
define the same lifecycle rule for terraform internal processing to happen as expected**

#### Template Files

We haven't seen these yet, but there's yet another type of data source: a `data "template_file"` resource allows us to load a local
template file and pass values into for rendering and then for use in another resource. In this case, we pass in our rendered templates
as the startup scripts for our servers

### OK, back to our apply results

OK, your apply should have finished by now, so let's look at some of what happened

```
module.backend.aws_security_group.web_server: Creating...
module.frontend.aws_security_group.web_server: Creating...
module.frontend.aws_security_group.alb: Creating...
module.backend.aws_security_group.alb: Creating...
module.frontend.aws_alb_target_group.web_servers: Creating...
module.backend.aws_alb_target_group.web_servers: Creating...
module.backend.aws_security_group.web_server: Creation complete after 2s [id=sg-02068e4048fbcc18f]
module.frontend.aws_security_group.web_server: Creation complete after 2s [id=sg-0d76eb4768e6b0b4a]
module.backend.aws_security_group_rule.web_server_allow_all_outbound: Creating...
module.frontend.aws_security_group_rule.web_server_allow_ssh_inbound: Creating...
module.backend.aws_security_group_rule.web_server_allow_ssh_inbound: Creating...
module.frontend.aws_security_group_rule.web_server_allow_all_outbound: Creating...
module.backend.aws_launch_configuration.microservice: Creating...
module.frontend.aws_security_group.alb: Creation complete after 2s [id=sg-02a4559b9f8079898]
module.backend.aws_security_group.alb: Creation complete after 2s [id=sg-04e85a74cb150043f]
module.frontend.aws_security_group_rule.alb_allow_http_inbound: Creating...
module.frontend.aws_security_group_rule.allow_all_outbound: Creating...
module.frontend.aws_alb.web_servers: Creating...
module.backend.aws_alb_target_group.web_servers: Creation complete after 2s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:targetgroup/backend/e48104a050c4ce06]
module.frontend.aws_security_group_rule.web_server_allow_http_inbound: Creating...
module.frontend.aws_alb_target_group.web_servers: Creation complete after 3s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:targetgroup/frontend/3fa34a0f7fe2e643]
module.backend.aws_security_group_rule.web_server_allow_http_inbound: Creating...
module.backend.aws_security_group_rule.web_server_allow_ssh_inbound: Creation complete after 1s [id=sgrule-1244802946]
module.frontend.aws_security_group_rule.web_server_allow_ssh_inbound: Creation complete after 1s [id=sgrule-1288178588]
module.backend.aws_alb.web_servers: Creating...
module.backend.aws_security_group_rule.allow_all_outbound: Creating...
module.frontend.aws_security_group_rule.allow_all_outbound: Creation complete after 1s [id=sgrule-98104006]
module.backend.aws_security_group_rule.alb_allow_http_inbound: Creating...
module.backend.aws_launch_configuration.microservice: Creation complete after 1s [id=terraform-20190623035509224100000001]
module.frontend.aws_security_group_rule.web_server_allow_all_outbound: Creation complete after 2s [id=sgrule-4278298275]
module.backend.aws_security_group_rule.web_server_allow_all_outbound: Creation complete after 2s [id=sgrule-3337988328]
module.frontend.aws_security_group_rule.alb_allow_http_inbound: Creation complete after 2s [id=sgrule-2187735113]
module.backend.aws_security_group_rule.allow_all_outbound: Creation complete after 2s [id=sgrule-2792934032]
module.backend.aws_security_group_rule.web_server_allow_http_inbound: Creation complete after 7s [id=sgrule-2471032756]
module.frontend.aws_security_group_rule.web_server_allow_http_inbound: Creation complete after 8s [id=sgrule-3635756729]
module.backend.aws_security_group_rule.alb_allow_http_inbound: Creation complete after 8s [id=sgrule-2755188117]
module.frontend.aws_alb.web_servers: Still creating... [10s elapsed]
module.backend.aws_alb.web_servers: Still creating... [10s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [20s elapsed]
module.backend.aws_alb.web_servers: Still creating... [20s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [30s elapsed]
module.backend.aws_alb.web_servers: Still creating... [30s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [40s elapsed]
module.backend.aws_alb.web_servers: Still creating... [40s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [50s elapsed]
module.backend.aws_alb.web_servers: Still creating... [50s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [1m0s elapsed]
module.backend.aws_alb.web_servers: Still creating... [1m0s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [1m10s elapsed]
module.backend.aws_alb.web_servers: Still creating... [1m10s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [1m20s elapsed]
module.backend.aws_alb.web_servers: Still creating... [1m20s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [1m30s elapsed]
module.backend.aws_alb.web_servers: Still creating... [1m30s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [1m40s elapsed]
module.backend.aws_alb.web_servers: Still creating... [1m40s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [1m50s elapsed]
module.backend.aws_alb.web_servers: Still creating... [1m50s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [2m0s elapsed]
module.backend.aws_alb.web_servers: Still creating... [2m0s elapsed]
module.frontend.aws_alb.web_servers: Still creating... [2m10s elapsed]
module.backend.aws_alb.web_servers: Still creating... [2m10s elapsed]
module.frontend.aws_alb.web_servers: Creation complete after 2m16s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:loadbalancer/app/frontend/018200e4365b3087]
module.frontend.aws_alb_listener.http: Creating...
module.frontend.aws_alb_listener.http: Creation complete after 0s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:listener/app/frontend/018200e4365b3087/d559474fe6c9845a]
module.frontend.aws_alb_listener_rule.send_all_to_web_servers: Creating...
module.frontend.aws_alb_listener_rule.send_all_to_web_servers: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:listener-rule/app/frontend/018200e4365b3087/d559474fe6c9845a/363224e13f266318]
module.backend.aws_alb.web_servers: Still creating... [2m20s elapsed]
module.backend.aws_alb.web_servers: Still creating... [2m30s elapsed]
module.backend.aws_alb.web_servers: Creation complete after 2m37s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:loadbalancer/app/backend/477fbbf6e6316f7b]
module.frontend.data.template_file.user_data: Refreshing state...
module.backend.aws_alb_listener.http: Creating...
module.frontend.aws_launch_configuration.microservice: Creating...
module.backend.aws_alb_listener.http: Creation complete after 0s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:listener/app/backend/477fbbf6e6316f7b/2e6f4fecf2d93316]
module.backend.aws_alb_listener_rule.send_all_to_web_servers: Creating...
module.backend.aws_autoscaling_group.microservice: Creating...
module.backend.aws_alb_listener_rule.send_all_to_web_servers: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-east-2:946320133426:listener-rule/app/backend/477fbbf6e6316f7b/2e6f4fecf2d93316/b65e22fdca8b804b]
module.frontend.aws_launch_configuration.microservice: Creation complete after 1s [id=terraform-20190623035747150700000002]
module.frontend.aws_autoscaling_group.microservice: Creating...
module.backend.aws_autoscaling_group.microservice: Still creating... [10s elapsed]
module.frontend.aws_autoscaling_group.microservice: Still creating... [10s elapsed]
module.backend.aws_autoscaling_group.microservice: Still creating... [20s elapsed]
module.frontend.aws_autoscaling_group.microservice: Still creating... [20s elapsed]
module.backend.aws_autoscaling_group.microservice: Still creating... [30s elapsed]
module.frontend.aws_autoscaling_group.microservice: Still creating... [30s elapsed]
module.backend.aws_autoscaling_group.microservice: Still creating... [40s elapsed]
module.frontend.aws_autoscaling_group.microservice: Still creating... [40s elapsed]
module.backend.aws_autoscaling_group.microservice: Still creating... [50s elapsed]
module.frontend.aws_autoscaling_group.microservice: Still creating... [50s elapsed]
module.backend.aws_autoscaling_group.microservice: Still creating... [1m0s elapsed]
module.frontend.aws_autoscaling_group.microservice: Still creating... [1m0s elapsed]
module.backend.aws_autoscaling_group.microservice: Creation complete after 1m7s [id=terraform-20190623035509224100000001]
module.frontend.aws_autoscaling_group.microservice: Creation complete after 1m6s [id=terraform-20190623035747150700000002]

Apply complete! Resources: 26 added, 0 changed, 0 destroyed.

Outputs:

backend_url = http://internal-backend-412928292.us-east-2.elb.amazonaws.com:80/
frontend_url = http://frontend-1508950933.us-east-2.elb.amazonaws.com:80/
```

Most of our output we don't need to look too closely at, but let's note a few things:

* We're able to track how long particular resources take to get created
* Terraform's HCL declarative nature means it can abstract some of the complexity of getting the job done away from the user. Some of the work going on behind the scenes in the above apply is happening in parallel depending on what Terraform has figured out from things like interpreted dependencies and the `depends_on` and `lifecycle` points we discussed above.

The last thing to note are the outputs. Our computed backend and frontend URLs are output for us. So, it's just a matter of
seeing if everything is up-and-running using these values. Let's check the frontend URL first. Open your browser and navigate to the
frontend URL. You should get something like:

```
Hello from frontend
Response from backend:

{"text": "Hello from backend"}
```

_If your frontend endpoint isn't up yet, just give it a little time. Autoscaling groups in combination with launch configurations can take
some time to actually spin up the EC2 instances. In addition, we also have a boot script running that is run to bring up the server(s) once
the EC2 instances themselves are up. So, yeah, it could take just a bit._

So, we can see that our frontend is working. We're hitting the application load balancer URL, so everything is routing correctly through
the load balancer to our EC2 instances actually running the service code. Including, we can see that the frontend is correctly communicating
through the backend load balancer to the backend server or servers. So, we also have our backend load balancer URL. Let's try to open that
in the browser.

Did it work? If not, can you figure out why not?

### What else?

If you have more time, feel free to play around with the project and/or module code to change things in the infrastructure you just brought up.

* Can you trigger certain things that require fully recreating resources vs just changing them in place?
* Can you break your app? I'm sure you can, but can you break it in a way where you can fix it again?

Feel free to poke around in the AWS console. It can be particularly interesting to look at EC2-related stuff there when it comes to autoscaling
groups, load balancers and such. It's useful to see that other students have their resources intermingled with yours. Be respectful of them.
Your Terraform state is completely separate from your fellow students, and even though very common resources can live beside each other like this,
we can manage them with a completely different state.

### Finishing off this exercise

Let's destroy everything before we move on. **PLEASE make sure you do it for this exercise especially**

```
terraform destroy
```