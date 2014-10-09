#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Run Ansible manually on a host managed by Vagrant

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

 #{{{ Variables
inventory_file="${PWD}/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
ssh_user=vagrant
private_key_path="/opt/vagrant/embedded/gems/gems/vagrant-1.6.5/keys/vagrant"
#}}}
#{{{  Functions

usage() {
cat << _EOF_
Usage: ${0} HOST MODULE [ARGS]
Runs Ansible manually on a host controlled by Vagrant. Run this script from the
same directory as the Vagrantfile.

  HOST    the host to be contacted
  MODULE  the Ansible module to be executed
  ARGS    other arguments that are passed on to ansible verbatim
_EOF_
}

#}}}
#{{{ Command line parsing

if [[ "$#" -lt "2" ]]; then
    echo "Expected at least 2 arguments, got $#" >&2
    usage
    exit 2
fi

vagrant_host=$1
ansible_module=$2
shift; shift;

# }}}
# Script proper

ansible \
  --inventory="${inventory_file}" \
  --connection=ssh \
  --user="${ssh_user}" \
  --private-key="${private_key_path}" \
  ${vagrant_host} \
  --module-name=${ansible_module} \
  "$@"

