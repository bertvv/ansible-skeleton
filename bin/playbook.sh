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
private_key_path="/opt/vagrant/embedded/gems/gems/vagrant-1.6.5/keys/vagrant"
#}}}
#{{{  Functions

usage() {
cat << _EOF_
Usage: ${0} PLAYBOOK [ARGS]
Runs Ansible-playbook manually on a host controlled by Vagrant. Run this script
from the same directory as the Vagrantfile.

  PLAYBOOK  the host to be run
  ARGS      other options that are passed on to ansible-playbook verbatim
_EOF_
}

 #}}}
#  {{{ Command line parsing

if [[ "$#" -lt "1" ]]; then
    echo "Expected at least 1 arguments, got $#" >&2
    usage
    exit 2
fi

if [[ -f "${1}" ]]; then
  playbook="${1}"
  shift
else
  echo "Not a file: ${1}" >&2
  usage
  exit 1
fi


# }}}
# Script proper

ansible-playbook \
  ${playbook} \
  --inventory="${inventory_file}" \
  --connection=ssh \
  --user="${ssh_user}" \
  --private-key="${private_key_path}" \
  "$@"

