# Malkovich

Facilitates developing and deploying Puppet modules with Capistrano. Also includes a convenience for Vagrant.

This is a work in progress. Currently targets Ubuntu 12.04.

## Installation

In your Capfile add

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

Then create the shell provisioner script in .vagrant/ with:

```bash
$ cap vagrant
```

The `vagrant` task by default assumes your ssh key is in `~/.ssh/id_rsa`.  It will attempt to create a public key file at `~/.ssh/id_rsa.pub` if one doesn't already exist. The key filenames can be set with `private_key_filename` and `public_key_filename`.

After the shell provisioner is written, inside the config block in your Vagrantfile add:

```rb
config.vm.provision :shell, :path => '.vagrant/shell_provisioner'
```

You might also set the network address for the VM so you can define the server in the Capfile, for example:

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
  server '192.168.1.42', :app
end
```

Then invoke a stage task on the Capistrano command line before any primary task, e.g.:

```bash

$ cap dev bootstrap
```

## Bootstrap

A bootstrap Capistrano task is provided to prepare a base image with installed Puppet. This is for Ubuntu 12.04 precise.

One approach is to run bootstrap once on a clean image, and then create a new EC2 image or Vagrant box from that. Then destroy the running machine and change your Vagrantfile to use the new image, also removing the shell provisioner.

Now you can spin up this new machine as a starting point for Puppet module development.

## Puppet tasks

Use the `define_puppet_tasks` method in your Capfile to match up Capistrano roles with Puppet manifests. E.g., :

```rb
define_puppet_tasks :web
```

will create a task called `puppet:web`, which when run will:

* Upload the directory `puppet/` to the servers with the role `:web`
    * Assumes `puppet/modules` is the path to the modules
* Use the `puppet` command on the servers to apply the manifest `puppet/manifests/web.pp`

## Required values

You must define at least one stage.

## Default values

Some default Capistrano values are set such as user. See defaults.rb for more. These work with the Vagrant shell provisioner and Canonical EC2 images.

## Capistrano tasks

In addition to the `puppet:` tasks defined in your Capfile, there are a couple of other useful tasks such as `uptime` and `upgrade`. View them all with:

```bash
$ cap -T
```

## Example

* Capfile

```rb
load 'deploy'
require 'malkovich/capistrano'

set :application, 'myapp'

task :qa do
  set :stage, 'qa'
  server 'qa.myapp.com', :web
end

define_puppet_tasks :web
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
