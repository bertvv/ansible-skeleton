# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rbconfig'
require 'yaml'

VAGRANTFILE_API_VERSION = '2'

hosts = YAML.load_file('vagrant_hosts.yml')

# {{{ Helper functions

def is_windows
  RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
end

def provision_ansible(config)
  if is_windows
    # Provisioning configuration for shell script.
    config.vm.provision "shell" do |sh|
      sh.path = "scripts/playbook_win.sh"
    end
  else
    # Provisioning configuration for Ansible (for Mac/Linux hosts).
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/site.yml"
      ansible.sudo = true
    end
  end
end

# Set options for the network interface configuration. A host should at least
# get an IP address. Other values are optional, and can include:
# - netmask (default value = 255.255.255.0
# - mac
# - auto_config (if false, Vagrant will not configure this network interface
# - intnet (if true, an internal network adapter will be created instead of a
#   host-only adapter)
def network_options(host)
  options = {
    ip: host['ip'],
    netmask: host['netmask'] ||= '255.255.255.0'
  }

  # TODO: if ip: wasn't specified, add
  #   options[:type] = 'dhcp'
  # See https://docs.vagrantup.com/v2/networking/private_network.html

  if host.has_key?('mac')
    options[:mac] = host['mac'].gsub(/[-:]/, '')
  end
  if host.has_key?('auto_config')
    options[:auto_config] = host['auto_config']
  end
  if host.has_key?('intnet') && host['intnet']
    options[:virtualbox__intnet] = true
  end

  options
end

# }}}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'centos70-nocm'

  hosts.each do |host|
    config.vm.define host['name'] do |node|

      node.vm.hostname = host['name']

      node.vm.network :private_network, network_options(host)

      node.vm.synced_folder 'ansible/', '/etc/ansible', mount_options: ["fmode=666"]

      node.vm.provider :virtualbox do |vb|
        vb.name = host['name']
      end
    end
  end
  provision_ansible(config)
end

