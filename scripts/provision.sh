#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Run Ansible manually on a host managed by Vagrant. Fix the path to the Vagrant
# private key before use!

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Variables
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
inventory_file="${script_dir}/../.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
ssh_user=vagrant
private_key_path="${HOME}/.vagrant.d/insecure_private_key"
#}}}
#{{{  Functions

usage() {
cat << _EOF_
Usage: ${0} [PLAYBOOK] [ARGS]
Runs Ansible-playbook manually on a host controlled by Vagrant. Run this script
from the same directory as the Vagrantfile.

  PLAYBOOK  the playbook to be run (default: ansible/site.yml)
  ARGS      other options that are passed on to ‘ansible-playbook’ verbatim
_EOF_
}

 #}}}
#  {{{ Command line parsing

if [ $# -gt 0 -a -f "${1}" ]; then
  playbook="${1}"
  shift
else
  playbook="${script_dir}/../ansible/site.yml"
fi


# }}}
# Script proper

ansible-playbook \
  "${playbook}" \
  --inventory="${inventory_file}" \
  --connection=ssh \
  --user="${ssh_user}" \
  --private-key="${private_key_path}" \
  "$@"

