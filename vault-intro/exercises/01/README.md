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

This will start up our Vault server in the foreground of this terminal window and should output something similar to the below:

```
==> Vault server configuration:

             Api Address: http://0.0.0.0:8200
                     Cgo: disabled
         Cluster Address: https://0.0.0.0:8201
              Go Version: go1.16.7
              Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
              Listener 2: tcp (addr: "0.0.0.0:8201", cluster address: "0.0.0.0:8202", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: info
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: file
                 Version: Vault v1.8.2
             Version Sha: aca76f63357041a43b49f3e8c11d67358496959f

==> Vault server started! Log data will stream in below:

2021-09-22T18:08:54.882Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2021-09-22T18:08:54.891Z [INFO]  core: security barrier not initialized
2021-09-22T18:08:54.891Z [INFO]  core: security barrier initialized: stored=1 shares=1 threshold=1
2021-09-22T18:08:54.892Z [INFO]  core: post-unseal setup starting
2021-09-22T18:08:54.906Z [INFO]  core: loaded wrapping token key
2021-09-22T18:08:54.907Z [INFO]  core: successfully setup plugin catalog: plugin-directory=""
2021-09-22T18:08:54.907Z [INFO]  core: no mounts; adding default mount table
2021-09-22T18:08:54.911Z [INFO]  core: successfully mounted backend: type=cubbyhole path=cubbyhole/
2021-09-22T18:08:54.913Z [INFO]  core: successfully mounted backend: type=system path=sys/
2021-09-22T18:08:54.915Z [INFO]  core: successfully mounted backend: type=identity path=identity/
2021-09-22T18:08:54.923Z [INFO]  core: successfully enabled credential backend: type=token path=token/
2021-09-22T18:08:54.924Z [INFO]  core: restoring leases
2021-09-22T18:08:54.925Z [INFO]  rollback: starting rollback manager
2021-09-22T18:08:54.926Z [INFO]  expiration: lease restore complete
2021-09-22T18:08:54.926Z [INFO]  identity: entities restored
2021-09-22T18:08:54.926Z [INFO]  identity: groups restored
2021-09-22T18:08:54.927Z [INFO]  core: post-unseal setup complete
2021-09-22T18:08:54.928Z [INFO]  core: root token generated
2021-09-22T18:08:54.928Z [INFO]  core: pre-seal teardown starting
2021-09-22T18:08:54.928Z [INFO]  rollback: stopping rollback manager
2021-09-22T18:08:54.929Z [INFO]  core: pre-seal teardown complete
2021-09-22T18:08:54.929Z [INFO]  core.cluster-listener.tcp: starting listener: listener_address=127.0.0.1:8201
2021-09-22T18:08:54.929Z [ERROR] core.cluster-listener.tcp: error starting listener: error="listen tcp 127.0.0.1:8201: bind: address already in use"
2021-09-22T18:08:54.929Z [INFO]  core.cluster-listener.tcp: starting listener: listener_address=0.0.0.0:8202
2021-09-22T18:08:54.929Z [INFO]  core.cluster-listener: serving cluster requests: cluster_listen_address=[::]:8202
2021-09-22T18:08:54.929Z [INFO]  core: post-unseal setup starting
2021-09-22T18:08:54.930Z [INFO]  core: loaded wrapping token key
2021-09-22T18:08:54.930Z [INFO]  core: successfully setup plugin catalog: plugin-directory=""
2021-09-22T18:08:54.931Z [INFO]  core: successfully mounted backend: type=system path=sys/
2021-09-22T18:08:54.932Z [INFO]  core: successfully mounted backend: type=identity path=identity/
2021-09-22T18:08:54.932Z [INFO]  core: successfully mounted backend: type=cubbyhole path=cubbyhole/
2021-09-22T18:08:54.933Z [INFO]  core: successfully enabled credential backend: type=token path=token/
2021-09-22T18:08:54.933Z [INFO]  core: restoring leases
2021-09-22T18:08:54.934Z [INFO]  identity: entities restored
2021-09-22T18:08:54.934Z [INFO]  identity: groups restored
2021-09-22T18:08:54.935Z [INFO]  core: post-unseal setup complete
2021-09-22T18:08:54.935Z [INFO]  core: vault is unsealed
2021-09-22T18:08:54.939Z [INFO]  core: successful mount: namespace="" path=secret/ type=kv
2021-09-22T18:08:54.943Z [INFO]  expiration: lease restore complete
2021-09-22T18:08:54.943Z [INFO]  secrets.kv.kv_a143f563: collecting keys to upgrade
2021-09-22T18:08:54.943Z [INFO]  secrets.kv.kv_a143f563: done collecting keys: num_keys=1
2021-09-22T18:08:54.943Z [INFO]  secrets.kv.kv_a143f563: upgrading keys finished
2021-09-22T18:08:54.946Z [INFO]  rollback: starting rollback manager
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variable:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: <UNSEAL KEY>
Root Token: <ROOT TOKEN>

Development mode should NOT be used in production installations!
```

Here we can see Vault's dev server startup. It prints out the configuration, the core component's info logs, and two tokens: The unseal key + the root token. The Root Token is very important to us as we'll utilize that token as our easy means of providing **Authentication** for this exercise. Copy that token.

Since our Vault server is running in the foreground and we still need to execute some Vault CLI commands, let's start up a new terminal session so we can let the Vault Server keep running. 3 ways to do this:

1. Window > New Terminal
1. Option + T
1. Click the little Green plus button next to your existing terminal tab.

Now that you have that token and we've started a new terminal session, let's set two environment variables to let our Vault CLI know how to speak with Vault:

```bash
$ export VAULT_TOKEN=<ROOT TOKEN COPIED FROM VAULT SERVER OUTPUT>
$ export VAULT_ADDR=http://127.0.0.1:8201
```

Awesome... now let's try out the Vault CLI!

## Using the Vault CLI

First, let's try using the Vault KV (Key Value) v2 Secret Engine (which is enabled by default in the dev server) to store some secret info in Vault:

```bash
$ vault kv get secret/hello
```

You should receive a message that states now value was found... so let's put in a value:

```bash
$ vault kv set secret/hello foo=world
$ vault kv get secret/hello
```

Easy, right? We're now storing a value within our `secret/hello` path and we're able to get out that value. Let's try updating it:

```bash
$ vault kv put secret/hello foo=world bar=universe
$ vault kv get secret/hello
```

We can see from this example that we're able to store not just a single key / value pair, but a map of key value pairs via the KV secret engine. This means our data structures don't need to be entirely flat (though nested secrets in Vault are typically discouraged).

We can also see that as we push new information into our secret, we are incrementing the version of that secret. This is one of the important distinctions between the KV v2 and KV v1 Secret Engines: V2 stores older versions. Let's get an older version:

```bash
$ vault kv get -version=1 secret/hello
```

This allows us to get the old value from the previous version. This is great as it means if we accidentally push a bad secret then we can still rollback to the old value OR we can have our application code reference a specific version so that we can properly react to updating the secret without unintended consequences.

That's all we'll check out for now -- Let's head back to our lecture and learn a bit more about Vault.

