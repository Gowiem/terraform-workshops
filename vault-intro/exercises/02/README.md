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

## Running Terraform Against Vault



