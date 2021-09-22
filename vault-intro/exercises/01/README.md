# Vault Exercise #1: Dev Server + KV-v2 Usage

In this exercise, we're going to take a look at running Vault locally with their dev server and interacting with it from the command line. This exercise utilizes Docker Compose to start up the Vault server and the Vault CLI to interact with Vault as a client.

## Setup

First things first, let's install Vault onto our Cloud9 machine so we can utilize the Vault CLI:

```bash
$ sudo yum install -y vault
$ vault --help
```

You should see a successful vault CLI help message appear -- Easy install success!

Now, let's install docker-compose:

```bash
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --help
```

Again, you should see a successful compose help message.

Finally, let's start up the Vault dev server using compose:

```bash
$ docker-compose up
```
