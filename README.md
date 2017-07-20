# Vagrant Openssh Passwd Plugin

[![Build Status](https://travis-ci.org/taliesins/vagrant-openssh-passwd.svg)](https://travis-ci.org/taliesins/vagrant-openssh-passwd)
[![Coverage Status](https://coveralls.io/repos/taliesins/vagrant-openssh-passwd/badge.svg?branch=master)](https://coveralls.io/r/taliesins/vagrant-openssh-passwd?branch=master)
[![Gem Version](https://badge.fury.io/rb/vagrant-openssh-passwd.svg)](http://badge.fury.io/rb/vagrant-openssh-passwd)

A Vagrant Plugin that makes regenerates your passwd and group files for OpenSSH on Windows, so that you can use machine name prefix when using ssh to the box. 

## Why do I need this?

TL;DR; You need this if you use Windows + OpenSSH + Rsync + join Active Directory.

When spinning up a new Windows machine from a base box, it will have the name of the basebox. During the first boot, Vagrant will remote in and change the hostname. This is not a problem if you don't specify a machine prefix when connecting via SSH e.g. "vagrant" vs "webserver1+vagrant". 

When you join a machine to Active Directory and wish to SSH into the box with local user credentials, you need to specify the hostname and username otherwise it defaults to looking the user up in Active Directory. During the first boot, your machine will not be connected to Active Directory and it will join Active Directory and then reboot. So for the first Rsync we will not be connected to Active Directory. This is not a problem if you do specify a machine prefix when connecting via SSH e.g. "webserver1+vagrant" vs "vagrant". But the base box that we cloned from is configured to only allow "basebox+vagrant" or "vagrant".

To tackle this clash, if directly after changing the hostname we reconfigure OpenSsh with mkpasswd and mkgroup and then restart the service to apply the configuration, then "webserver1+vagrant" will be allowed to be used when it runs RSync folder sync.

## Installation

```vagrant plugin install vagrant-openssh-passwd```

## Usage

In your Vagrantfile, add the following plugin and configure to your needs:

```ruby
config.vm :openssh_passwd do |openssh_passwd|
    openssh_passwd.generate_passwd=true
    openssh_passwd.generate_group=true
    openssh_passwd.passwd_path='C:\\Program Files\\OpenSSH\\etc\\passwd'
    openssh_passwd.mkpasswd_path='C:\\Program Files\\OpenSSH\bin\\mkpasswd.exe'
    openssh_passwd.group_path='C:\\Program Files\\OpenSSH\\etc\\group'
    openssh_passwd.mkgroup_path='C:\\Program Files\\OpenSSH\bin\\mkgroup.exe'
end
```
## Example

There is a [sample](https://github.com/taliesins/vagrant-openssh-passwd/tree/master/development) Vagrant setup used for development of this plugin. 
This is a great real-life example to get you on your way.

### Supported Environments

Currently the plugin supports any Windows environment with Powershell 3+ installed (2008r2, 2012r2 should work nicely) and have OpenSSH installed on the basebox.

## Development

Before getting started, read the Vagrant plugin [development basics](https://docs.vagrantup.com/v2/plugins/development-basics.html) and [packaging](https://docs.vagrantup.com/v2/plugins/packaging.html) documentation.

You will need Ruby 2.1.5 and Bundler v1.12.5 installed before proceeding.

_NOTE_: it _must_ be bundler v1.12.5 due to a hard dependency in Vagrant at this time.

```
git clone git@github.com:taliesins/vagrant-openssh-passwd.git
cd vagrant-openssh-passwd
bundle install
```

Run tests:
```
bundle exec rake spec
```

Run Vagrant in context of current vagrant-openssh-passwd plugin:
```
cd <directory>
bundle exec vagrant up
```

There is a test Vagrant DSC setup in `./development` that is a good example of a simple acceptance test.

### Multiple Bundlers?

If you have multiple Bundler versions, you can still use 1.12.5 with the following:

```
bundle _1.12.5_ <command>
```

e.g. `bundle _1.12.5_ exec rake spec`

## Uninstallation

```vagrant plugin uninstall vagrant-openssh-passwd```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vagrant-openssh-passwd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Squash commits & push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
