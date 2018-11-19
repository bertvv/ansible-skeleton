# Ansible Skeleton

An opinionated skeleton that considerably simplifies setting up an Ansible project with a development environment powered by Vagrant.

Advantages include:

- It works on Linux, MacOS **and** Windows (that is normally unsupported by Ansible)
- You don't need to edit the `Vagrantfile`. Hosts are defined in a simple Yaml format (see below). Setting up a multiple-VM Vagrant environment becomes almost trivial. I gave a [lightning talk about this](https://youtu.be/qJ0VNO6z68M) at [Config Management Camp 2016 Ghent](http://cfgmgmtcamp.eu/) ([slides here](http://www.slideshare.net/bertvanvreckem/one-vagrantfile-to-rule-them-all)).

See also the companion projects:

- [ansible-role-skeleton](https://github.com/bertvv/ansible-role-skeleton): scaffolding code for multi-platform Ansible roles with Vagrant and Docker test environments
- [vagrant-shell-skeleton](https://github.com/bertvv/vagrant-shell-skeleton): A Vagrant environment with shell provisioning.
- [ansible-toolbox](https://github.com/bertvv/ansible-toolbox/): useful scripts to be used in combination with the skeleton-projects.

If you like/use this role, please consider giving it a star. Thanks!

## Installation

On the management node, make sure you have installed recent versions of:

- [VirtualBox](https://virtualbox.org/)
- [Vagrant](https://vagrantup.com/)
- [Git](https://git-scm.com/) and for Windows hosts also Git Bash. If you install Git with default settings (i.e. always click "Next" in the installer), you should be fine.
- Ansible (only on Mac/Linux)

You can either clone this project or use the provided initialization script.

When cloning, choose another name for the target directory.

```ShellSession
> git clone https://github.com/bertvv/ansible-skeleton.git my-ansible-project
```

After cloning, it's best to remove the `.git` directory and initialise a new repository. The history of the skeleton code is irrelevant for your Ansible project.

You can find an [initialization script](https://github.com/bertvv/ansible-toolbox/blob/master/bin/atb-init.sh) in my [ansible-toolbox](https://github.com/bertvv/ansible-toolbox/) that automates the process (including creating an empty Git repository).

```ShellSession
> atb-init my-ansible-project
```

This will download the latest version of the skeleton from Github, initialize a Git repository, do the first commit, and, optionally, install any specified role.

```ShellSession
> atb-init my-ansible-project bertvv.el7 bertvv.httpd
```

This will create the skeleton and install roles `bertvv.el7` and `bertvv.httpd` from Ansible Galaxy.

## Getting started

First, modify the `Vagrantfile` to select your favourite base box. I use a CentOS 7 base box, from the [Bento project](https://app.vagrantup.com/bento/). This is probably the only time you need to edit the `Vagrantfile`.

The `vagrant-hosts.yml` file specifies the nodes that are controlled by Vagrant. You should at least specify a `name:`, other settings (see below) are optional. A host-only adapter is created and the given IP assigned to that interface. Other optional settings that can be specified:

**VirtualBox configuration:**

- `cpus`: The number of CPUs assigned to this VM.
- `memory`: The memory size in MB, if you want to set a size different from the base box default.
- `synced_folders`: A list of dicts that specify synced folders. Two keys, `src:` (the directory on the host system) and `dest:` (the mount point in the guest) are mandatory, another one, `options:` is, well, optional. The possible options are the same ones as specified in the [Vagrant documentation on synced folders](http://docs.vagrantup.com/v2/synced-folders/basic_usage.html). One caveat is that the option names should be prefixed with a colon, e.g. `owner:` becomes `:owner:`.

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

**Network settings:**

- `auto_config`: If set to `false`, Vagrant will not attempt to configure the network interface.
- `forwarded_ports`: A list of dicts with keys `host:` and `guest:` specifying which host port should be forwarded to which port on the VM.
- `intnet`: If set to `true`, the network interface will be attached to an internal network rather than a host-only adapter.
- `ip:` The IP address for the VM.
- `mac`: The MAC address to be assigned to the NIC. Several notations are accepted, including "Linux-style" (`00:11:22:33:44:55`) and "Windows-style" (`00-11-22-33-44-55`). The separator characters can be omitted altogether (`001122334455`).
- `netmask`: By default, the network mask is `255.255.255.0`. If you want another one, it should be specified.

**Provisioning:**

- `playbook`: On this host, execute a different playbook than the default `ansible/site.yml`
- `shell_always`: A list of dicts that specify commands to be run after booting the VM. There is one required key, `cmd:` that contains the command and any options/arguments.

## Adding hosts

As an example, a single host with hostname `srv001` is already defined. If you want to add new nodes, you should edit the following files:

- `vagrant-hosts.yml` so a Vagrant box is created. A few examples that also illustrate the optional settings.

```yaml
- name: srv002
  ip: 192.168.56.11
  auto_config: false

- name: srv003
  ip: 172.16.0.3
  netmask: 255.255.0.0
  intnet: true

- name: srv004
  ip: 192.168.56.14
  mac: "00:03:DE:AD:BE:EF"
  playbook: server.yml  # defaults to site.yml
```

- `site.yml` to assign roles to your nodes, e.g.:

```Yaml
- hosts: srv003
  become: true
  roles:
    - bertvv.rh-base
    - bertvv.httpd
```

## Defining groups

Ansible allows hosts to be organized into groups. In order to use this functionality, edit the file `vagrant-groups.yml`. The file should contain a dict with group names as keys and lists of member hosts as values.

In this example, two groups, `db` and `web` are defined:

```yaml
---
db:
  - srv001
web:
  - srv002
  - srv003
```

## Run with custom hosts/groups file

```ShellSession
VAGRANT_HOSTS='custom-vagrant-hosts.yml' vagrant up
```
or

```ShellSession
export VAGRANT_HOSTS='custom-vagrant-hosts.yml'
vagrant up
```

Likewise, set the environment variable `VAGRANT_GROUPS` to use a custom groups file.

## Worked example

Alice wants to set up an environment with several web servers, a load balancer and a database server. She first defines the groups:

```yaml
# group-vars.yml
---
db:
  - db001

lb:
  - lb001

web:
  - web001
  - web002
  - web003
```

Next, she assigns IP addresses to each VM in `vagrant-hosts.yml`:

```yaml
# vagrant-hosts.yml
---
- name: db001
  ip: 192.168.56.10
- name: lb001
  ip: 192.168.56.11
- name: web001
  ip: 192.168.56.21
- name: web002
  ip: 192.168.56.22
- name: web003
  ip: 192.168.56.23
```

Next, she starts with the following master playbook `site.yml`:

```yaml
# ansible/site.yml
---

- hosts: all
  tasks:
    - debug:
        msg: "This is {{ ansible_hostname }} in group {{ my_group }}"
```

The variable `ansible_hostname` is initialized automatically by Ansible, but `my_group` is not. Therefore, Alice defines it for each group, by editing an appropriately named Yaml file in `ansible/group_vars/` (only `web` and `db` are shown here):

```yaml
# ansible/group_vars/web.yml
---
my_group: web
```

```yaml
# ansible/group_vars/db.yml
---
my_group: db
```

Next, she can run `vagrant up`. The following transcript shows what you should see after running `vagrant provision db001 web001`:

```console
$ vagrant provision db001 web001
==> db001: Running provisioner: ansible...
    db001: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [debug] *******************************************************************
ok: [db001] => 
  msg: This is db001 in group db

PLAY RECAP *********************************************************************
db001                     : ok=1    changed=0    unreachable=0    failed=0   

==> web001: Running provisioner: ansible...
    web001: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [debug] *******************************************************************
ok: [web001] => 
  msg: This is web001 in group web

PLAY RECAP *********************************************************************
web001                     : ok=1    changed=0    unreachable=0    failed=0   
```

The master playbook can the be refined further, e.g.

```yaml
# ansible/site.yml
---

- hosts: web
  roles:
    - bertvv.rh-base
    - bertvv.httpd
- hosts: db
  roles:
    - bertvv.rh-base
    - bertvv.mariadb
# ...
```

Role variables can then be defined in `ansible/group_vars/`.

## Running tests with BATS

There's a discussion on whether Unit tests are necessary for Ansible. Indeed, with its declarative nature, Ansible largely takes away the need to check for certain things independently from the playbook definitions. For a bit more background, be sure to read through [this discussion about unit testing for Ansible](https://groups.google.com/forum/#!topic/ansible-project/7VhqDDtf6Js) on Google groups.

However, it is my opinion that playbooks don't cover everything (e.g. whether a config file generated from a template has the expected contents, given the values of variables used). I value some form of testing, independent of the configuration management system. Personally, I'm a fan of the [Bash Automated Testing System (BATS)](https://github.com/bats-core/bats-core). It's basically an extension of Bash, so anyone familiar with it should be able to use BATS.

Put your BATS test scripts in the `test/` directory and they will become available on your guest VMs as a synced folder, mounted in `/vagrant/test`. Scripts that you want to run on each host should be stored in the `test/` directory itself, scripts for individual hosts should be stored in subdirectories with the same name as the host (see example below). Inside the VM, run

```ShellSession
> sudo /vagrant/test/runbats.sh
```

to execute all tests relevant for that host. The script will install BATS if needed.

Suppose the `test/` directory is structured like the example below:

```ShellSession
test/
├── common.bats
├── runbats.sh
├── db001
│   └── db.bats
└── web001
    └── web.bats
```

On host `db001`, the scripts `common.bats` and `db.bats` will be executed, on host `web001`, it's `common.bats` and `web.bats`.

Tests must be defined for each host individually. If you want to run identical tests on several hosts, it's best to create a symlink, e.g.:

```console
$ ln -s web001 web002
```

Now, `web.bats` will also be executed on host `web002`.

## Contributors

- [Bert Van Vreckem](https://github.com/bertvv/) (maintainer)
- [Brian Stewart](https://github.com/thecodesmith)
- [Jeroen De Meerleer](https://github.com/JeroenED)
- [Mathias Stadler](https://github.com/MathiasStadler)
