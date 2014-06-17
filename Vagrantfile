# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rbconfig'
require 'yaml'

VAGRANTFILE_API_VERSION = '2'

hosts = YAML.load_file('vagrant_hosts.yml')

# {{{ Helper functions

def is_windows
  #RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  true
end

def provision_ansible(config, node)
  if is_windows
    # Provisioning configuration for shell script.
    config.vm.provision "shell" do |sh|
      sh.path = "ansible_win.sh"
    end
  else
    # Provisioning configuration for Ansible (for Mac/Linux hosts).
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/site.yml"
      ansible.sudo = true
    end
  end
end

# }}}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'misheska/centos65'
  hosts.each do |host|
    config.vm.define host['name'] do |node|
      node.vm.hostname = host['name']
      node.vm.network :private_network,
        ip: host['ip'],
        netmask: '255.255.255.0'
      node.vm.synced_folder 'ansible/', '/etc/ansible'

      node.vm.provider :virtualbox do |vb|
        vb.name = host['name']
      end

      provision_ansible(config, node)
    end
  end
end

