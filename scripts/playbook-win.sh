#!/bin/bash
# Source: https://github.com/geerlingguy/JJG-Ansible-Windows/blob/master/windows.sh

# Windows shell provisioner for Ansible playbooks, based on KSid's
# windows-vagrant-ansible: https://github.com/KSid/windows-vagrant-ansible
#
# @todo - Allow proxy configuration to be passed in via Vagrantfile config.
#
# @see README.md
# @author Jeff Geerling, 2014
# @version 1.0
#

#
# Bash shell settings: exit on failing commands, unbound variables
#
set -o errexit
set -o nounset
set -o pipefail

#
# Variables
#
readonly playbook=/vagrant/ansible/site.yml
readonly inventory=/vagrant/scripts/inventory.py

#
# Functions
#

# Print the Linux distribution
get_linux_distribution() {
  if user_exists vyos; then
    echo "vyos"
  elif [ -f /etc/redhat-release ]; then
    cut -f1 -d' ' /etc/redhat-release | tr "[:upper:]" "[:lower:]"
  fi
}

# Install Ansible on a Fedora system.
# The version in the repos is fairly current, so we'll install that
install_ansible_fedora() {
  echo "Installing Fedora from repositories"
  dnf -y install ansible
}

# Install Ansible on a CentOS system from EPEL
install_ansible_centos() {
  yum -y install epel-releas
  yun -y install ansible
}

# Checks if the specified user exists
user_exists() {
  user_name="${1}"
  getent passwd "${user_name}" > /dev/null
}
#
# Script proper
#

# If we're on a VyOS box, this script shouldn't be executed
if user_exists vyos; then
  exit 0
fi

if [ ! -f ${playbook} ]; then
  echo "Cannot find Ansible playbook ${playbook}."
  exit 1
fi

if [ ! -f ${inventory} ]; then
  echo "Cannot find inventory file ${inventory}."
  exit 2
fi

# Install Ansible and its dependencies if it's not installed already.
if [ ! -f /usr/bin/ansible ]; then
  "install_ansible_$(get_linux_distribution)"
fi

ansible-playbook "${playbook}" \
  --inventory-file="${inventory}" \
  --limit="${HOSTNAME}" \
  --extra-vars "is_windows=true" \
  --connection=local \
  "$@"
