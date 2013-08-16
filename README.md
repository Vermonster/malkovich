# Malkovich

Makes it reasonably easy to develop and deploy Puppet modules using Capistrano. Also includes a convenience for Vagrant.

This is a work in progress. Currently targets Ubuntu 12.04.

## Installation

In your `Capfile` add

```rb
require 'malkovich/capistrano'
```

## Vagrant

Use a script provisioner to create the ubuntu user with your public key.

Requires recent-ish version of Vagrant (e.g., 1.2.7).

First, initialize a VM with Ubuntu Precise:

```bash
$ vagrant init precise32 http://files.vagrantup.com/precise32.box
```

Then create the shell provisioner script in `.vagrant/` with:

```bash
$ cap vagrant
```

The `vagrant` task by default assumes your ssh key is in `~/.ssh/id_rsa`.
It will attempt to create a public key file at `~/.ssh/id_rsa.pub` if one doesn't already exist.
The key filenames can be set with `private_key_filename` and `public_key_filename`.

After the shell provisioner is written, inside the config block in your Vagrantfile add:

```rb
config.vm.provision :shell, :path => '.vagrant/shell_provisioner'
```

You might also set the network address for the VM so you can define the server in `Capfile`, for example:

```rb
config.vm.network :private_network, ip: "192.168.101.101"
```

Otherwise you can get it later from inside the VM using `ifconfig`.

Finally, boot up your Vagrant VM for the first time:

```bash
$ vagrant up
```

At this point, you may wish to run the `bootstrap`, described below.

## Stages

For each stage, define a Capistrano task where you set a vaule for `:stage` and other values:

```rb
task :qa do
  set :stage, 'qa'
  server 'qa.myapp.com', :app, :db
end
```

You can make a stage for your Vagrant VM:

```rb
task :dev do
  set :stage, 'dev'
  server '192.168.101.101', :app
end
```

Then invoke a stage task on the Capistrano command line before any primary task, e.g.:

```bash

$ cap dev bootstrap
```

## Bootstrap

A bootstrap Capistrano task is provided to prepare a base image with installed Puppet. This is for Ubuntu 12.04 precise.

One approach is to run bootstrap once on a clean image, and then create a new EC2 image or Vagrant box from that.
Then destroy the running machine and change your Vagrantfile to use the new image, also removing the shell provisioner.

Now you can use this new image as a starting point for Puppet module development.

## Puppet tasks

For every `.pp` file in `puppet/manifests` a Capistrano task will be created in the `puppet` namespace.
E.g., `puppet/manifests/web.pp` will result in the task `puppet:web` that can be run on stages.
When `puppet:web` is run it will upload `puppet/` to the servers with the `:web` role and use `puppet apply` to apply the `web` manifest.

This assumes `puppet/modules` is the path to the modules the manifest includes.

## Facts

Specifying a stage, a server and a role is enough to let you run your puppet manifests on your server, but in many cases it is useful to make arbitrary dynamic values available to your puppet modules when they run on the server.
The `fact` method makes this easy. For example,

```rb
task :qa do
  set :stage, 'qa'
  server 'qa.myapp.com', :app, :db
  fact :hostname, 'qa.myapp.com'
end
```

will make a `$hostname` variable available in your puppet manifests. This is achieved with Facter environment variables.

## Required values

You must define at least one stage for most tasks, except for example `vagrant`.

## Default values

Some default Capistrano values are set such as user. See defaults.rb for more.
Set your own values in `Capfile`.
These work with the Vagrant shell provisioner and Canonical EC2 images.

## Capistrano tasks

There are some other tasks such as `uptime` and `upgrade`. View them all with:

```bash
$ cap -T
```

## Example

* Capfile

```rb
load 'deploy'
require 'malkovich/capistrano'

task :qa do
  set :stage, 'qa'
  server 'qa.myapp.com', :web
end
```

* puppet/manifests/web.pp

```puppet
Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

include nginx
```

* puppet/modules/nginx/manifests/init.pp

```puppet
class nginx {
  /* ... */
}
```

* Apply the manifest

```bash
$ cap qa puppet:web
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
