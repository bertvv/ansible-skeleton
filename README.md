# Ansible Skeleton

An opinionated skeleton for an Ansible project with a development environment
powered by Vagrant. This should work on Linux, MacOS *and* Windows.

The goal of this skeleton is having an Ansible setup that works without modification both in the development environment (Vagrant + VirtualBox) and production. Therefore, the Ansible project is set up according to their [best practices](http://docs.ansible.com/playbooks_best_practices.html). This also implies the possibility of a multi-VM Vagrant setup.

Prerequisites on the VirtualBox host system:

* VirtualBox (>= 4.3.x)
* Vagrant (>= 1.6.x)
* Ruby (>= 2.0.0)
* Git (>= 1.9.x) and for Windows hosts also Git Bash

The guest systems are based on the [misheska/centos65](https://vagrantcloud.com/misheska/centos65) base box.

## Getting started

The `vagrant_hosts.yml` file specifies the boxes that are controlled by `Vagrantfile`. You should specify a `name:` and `ip:` for each.  . For now, two hosts are defined: `srv001` and `srv002`.

The `ansible/` directory contains the Ansible configuration, and should at least contain the standard `site.yml`. You can (and probably should) replace this directory by a Git submodule that can be used in your production environment.

If you want to add a box, you should edit these files:

* `vagrant_hosts.yml` so a Vagrant box is created:
 
  ```yaml
  -
    name: srv003
    ip: 192.168.56.13
  ```

* `inventory_dev` (the Ansible inventory file for your development environment) so Ansible will actually be able to manage it.
* `site.yml` to assign some roles to the box.

## Acknowledgements

The Windows bootstrap script is based on the MIT licensed work of:

* Kawsar Saiyeed: https://github.com/KSid/windows-vagrant-ansible
* Jeff Geerling: https://github.com/geerlingguy/JJG-Ansible-Windows


