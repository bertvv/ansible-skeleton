# Ansible Skeleton

An opinionated skeleton that considerably simplifies setting up an Ansible project with a development environment powered by Vagrant.

Advantages include:

- It works on Linux, MacOS **and** Windows (that is normally unsupported by Ansible)
- You don't need to edit the `Vagrantfile`. Hosts are defined in a simple Yaml format (see below). Setting up a multiple-VM Vagrant environment becomes almost trivial!

## Installation

Prerequisites on the management node:

* [VirtualBox](https://virtualbox.org/) (>= 4.3.x)
* [Vagrant](https://vagrantup.com/) (>= 1.7.x)
* [Git](https://git-scm.com/) (>= 1.9.x) and for Windows hosts also Git Bash. If you install Git with default settings (i.e. always click "Next" in the installer), you should be fine.

You can either clone this project or use the provided initialization script.

When cloning, choose another name for the target directory!

```ShellSession
$ git clone https://github.com/bertvv/ansible-skeleton.git my-ansible-project
```

On Windows, it is important to keep line endings in the Linux format:

```ShellSession
$ git clone --config core.autocrlf=input https://github.com/bertvv/ansible-skeleton.git my-ansible-project
```

An [initialization script](scripts/ansible-init.sh) is provided that simplifies the process. Download it and put it somewhere in your `${PATH}` (removing the extension `.sh`).

```ShellSession
$ ansible-init my-ansible-project
```

This will download the latest version of the skeleton from Github, initialize a Git repository, do the first commit, and, optionally, install any specified role.

```ShellSession
$ ansible-init my-ansible-project bertvv.el7 bertvv.httpd
```

This will create the skeleton and install roles `bertvv.el7` and `bertvv.httpd` from Ansible Galaxy.

## Getting started

First, modify the `Vagrantfile` to select your favourite base box. I use a CentOS 7 base box, based on [Mischa Taylor's Packer template](https://github.com/boxcutter/centos). This is the only time you need to edit the `Vagrantfile`.

The `ansible/` directory contains the Ansible configuration, and should at least contain the standard `site.yml`.

The `vagrant_hosts.yml` file specifies the nodes that are controlled by Vagrant. You should at least specify a `name:`, other settings (see below) are optional. A host-only adapter is created and the given IP assigned to that interface. Other optional settings that can be specified:

* `netmask`: by default, the network mask is `255.255.255.0`. If you want another one, it should be specified.
* `mac`: The MAC address to be assigned to the NIC. Several notations are accepted, including "Linux-style" (`00:11:22:33:44:55`) and "Windows-style" (`00-11-22-33-44-55`). The separator characters can be omitted altogether (`001122334455`).
* `intnet`: If set to `true`, the network interface will be attached to an internal network rather than a host-only adapter.
* `auto_config`: If set to `false`, Vagrant will not attempt to configure the network interface.
* `synced_folders`: A list of dicts that specify synced folders. Two keys, `src` (the directory on the host system) and `dest` (the mount point in the guest) are mandatory, another one, `options` is, well, optional. The possible options are the same ones as specified in the [Vagrant documentation on synced folders](http://docs.vagrantup.com/v2/synced-folders/basic_usage.html). One caveat is that the option names should be prefixed with a colon, e.g. `owner:` becomes `:owner:`.

```Yaml
- name: srv002
  synced_folders:
    - src: test
      dest: /tmp/test
    - src: www
      dest: /var/www/html
      options:
        :create: true
        :owner: root
        :group: root
        :mount_options: ['dmode=0755', 'fmode=0644']
```

## Adding hosts

For now, two hosts are defined: `srv001` and `srv002`. If you want to add new nodes, you should edit the following files:

* `vagrant_hosts.yml` so a Vagrant box is created. A few examples that also illustrate the optional settings.

```yaml
- name: srv003
  ip: 192.168.56.13
  auto_config: false

- name: srv004
  ip: 172.16.0.5
  netmask: 255.255.0.0
  intnet: true

- name: srv005
  ip: 192.168.56.14
  mac: "00:03:DE:AD:BE:EF"
```

* `site.yml` to assign roles to your nodes, e.g.:

```Yaml
- host: srv003
  sudo: true
  roles:
    - bertvv.el7
    - bertvv.httpd
```

## Running tests with BATS

There's a discussion on whether Unit tests are necessary for Ansible. Indeed, with its declarative nature, Ansible largely takes away the need to check for certain things independently from the playbook definitions. For a bit more background, be sure to read through [this discussion unit testing for Ansible](https://groups.google.com/forum/#!topic/ansible-project/7VhqDDtf6Js) on Google groups.

However, it is my opinion that playbooks don't cover everything (e.g. whether a config file generated from a template has the expected contents, given the values of variables used). I value some form of testing, independent of the configuration management system. I'm a fan of the [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats). It's basically an extension of Bash, so very accessible for any Unix-oriented system administrator. This skeleton supports BATS tests.

Put your BATS test scripts in the `test/` directory and they will become available on your guest VMs as a synced folder, mounted in `/vagrant/test`. Scripts that you want to run on each host should be stored in the `test/` directory itself, scripts for individual hosts should be stored in subdirectories with the same name as the host.

The script `runbats.sh`, when run inside the VM, will install BATS if needed and execute all test scripts for that host.

## Acknowledgements

The Windows bootstrap script is based on the MIT licensed work of:

* Kawsar Saiyeed: https://github.com/KSid/windows-vagrant-ansible
* Jeff Geerling: https://github.com/geerlingguy/JJG-Ansible-Windows


