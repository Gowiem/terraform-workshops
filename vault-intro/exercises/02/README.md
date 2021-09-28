# Vault Exercise #1: Dev Server + Terraform

In this exercise, we're going to take a look at running Vault locally with their dev server and interacting with it from Terraform. This exercise will utilize the same Docker Compose setup we launched in exercise #1 and then we'll have a Terraform project to interact with that still running docker container.

## Setup

First, let's check that our dev server is still running docker:

```bash
$ docker ps
```

You should see something similar to the below:

```
CONTAINER ID   IMAGE          COMMAND                  CREATED             STATUS             PORTS                                                           NAMES
<CONTAINER ID>   vault:latest   "docker-entrypoint.s…"   About an hour ago   Up About an hour   0.0.0.0:8200-8201->8200-8201/tcp, :::8200-8201->8200-8201/tcp   01_vault_1
```

As long as you see that then you're good to continue! However, if you don't see vault running then return to excercise 01 and follow the steps to get the dev server running.

## Administering Vault with Terraform

Let's start out with administering our new Vault cluster. To do that, let's change into the `admin` directory: `cd admin`

Ah so here we have a simple Terraform root module similar to what we've seen before. I encourage you to check it out and read the source, but after doing so let's run it:

```bash
$ terraform init
$ terraform plan -out run.plan
$ terraform apply run.plan
```

*NOTE*: You will be prompted to input the `legacy_password` variable as part of this run. Obviously, we don't have any real legacy password to set here, so feel free to enter any text you like. I do suggest thinking through the problem presented here though: Since I need to keep my secrets out of my source control, how I could I safely and securely provide the initial secret values that seed Vault for consumers? Feel free to ask any questions on this as it's a good discussion topic.

This Terraform run will do 3 things:

1. Creates a new instance of the KV V2 secret engine at the path `application/`
1. Create two new secrets at path `application/api_key` + `application/legacy_password`
1. Create a policy which provides `read` only access to those two new secrets.

Pretty cool! From this simple example, we can see how this setup can be extremely useful to administer Vault: We're able to properly manage the Vault offering via Infrastructure as Code so that we get all the benefits of a great secrets management platform and don't need to utilize ClickOps to provision anything. That's a big win for centralizing secrets management and ownership!

Let's move onto consuming those secrets via Terraform so we can pass them to our applications...

## Consuming Secrets from Vault with Terraform

Now that we're done with the `admin` root module, let's head to the client root module: `cd ../client`

Here, we have yet another small Terraform root module which I encourage you to read through carefully. After doing so, let's run it:

```bash
$ terraform init
$ terraform apply # We don't need to pass a plan or confirm for this apply... Can you guess why that is?
```

Cool! All this small root module just did is read in the newly created "generic" (KV V2) secrets and write them out as `output`s. Super simple, but the idea behind it is important: Our secrets are created, permissioned, and managed elsewhere; All we need to do as consumers is just authenticate to the Vault API with proper permissions to be able to read them and pass them downstream. This is immensely powerful in large organizations as it enables application developers to never even have to see their applications secrets as they just become a blind consumer to those values.

This has a ton of potential use-cases:

1. A legacy Application which can't (or hasn't yet) implemented pulling secrets from Vault directly can be passed secrets from Terraform.
1. You could provision a [PKI Certificate](https://www.vaultproject.io/docs/auth/cert) via Vault and pass the private key downstream to a load balancer you provision with Terraform.
1. Our AWS provider access key and secret key authentication for Terraform could even come from [the AWS auth method](https://www.vaultproject.io/docs/auth/aws) to enable easy, centralized AWS access.

We'll wrap here, but this should give you a solid foundation of how you can utilize Terraform + Vault together to create a more secure, automated system!

