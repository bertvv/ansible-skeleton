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
# Color definitions
readonly reset='\e[0m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'
readonly cyan='\e[0;36m'

readonly playbook=/vagrant/ansible/site.yml
readonly inventory=/vagrant/scripts/inventory.py

#
# Functions
#

main() {
  info "Running Ansible playbook ${playbook} locally on host ${HOSTNAME}."

  exit_on_vyos
  check_if_playbook_exists
  check_if_inventory_exists
  ensure_ansible_installed
  run_playbook "${@}"
}

exit_on_vyos() {
  # If we're on a VyOS box, this script shouldn't be executed
  if user_exists vyos; then
    debug "On VyOS, not running Ansible here"
    exit 0
  fi
}

check_if_playbook_exists() {
  if [ ! -f ${playbook} ]; then
    die "Cannot find Ansible playbook ${playbook}."
  fi
}

check_if_inventory_exists() {
  if [ ! -f ${inventory} ]; then
    die "Cannot find inventory file ${inventory}."
  fi
}

ensure_ansible_installed() {
  if ! is_ansible_installed; then
    distro=$(get_linux_distribution)
    "install_ansible_${distro}" || die "Distribution ${distro} is not supported"
  fi

  info "Ansible version"
  ansible --version
}

is_ansible_installed() {
  which ansible-playbook > /dev/null 2>&1
}

run_playbook() {
  info "Running the playbook"

  # Get absolute path to playbook command
  playbook_cmd=$(which ansible-playbook)

  set -x
  ${playbook_cmd} "${playbook}" \
    --inventory-file="${inventory}" \
    --limit="${HOSTNAME}" \
    --extra-vars "is_windows=true" \
    --connection=local \
    "$@"
  set +x
}



# Print the Linux distribution
get_linux_distribution() {

  if user_exists vyos; then

    echo "vyos"

  elif [ -f '/etc/redhat-release' ]; then

    # RedHat-based distributions
    cut --fields=1 --delimiter=' ' '/etc/redhat-release' \
      | tr "[:upper:]" "[:lower:]"

  elif [ -f '/etc/lsb-release' ]; then

    # Debian-based distributions
    grep DISTRIB_ID '/etc/lsb-release' \
      | cut --delimiter='=' --fields=2 \
      | tr "[:upper:]" "[:lower:]"

  fi
}

# Install Ansible on a Fedora system.
# The version in the repos is fairly current, so we'll install that
install_ansible_fedora() {
  info "Fedora: installing Ansible from distribution repositories"
  dnf -y install ansible
}

# Install Ansible on a CentOS system from EPEL
install_ansible_centos() {
  info "CentOS: installing Ansible from the EPEL repository"
  yum -y install epel-release
  yum -y install ansible
}

# Install Ansible on a recent Ubuntu distribution, from the PPA
install_ansible_ubuntu() {
  info "Ubuntu: installing Ansible from PPA"
  # Remark: on older Ubuntu versions, it's python-software-properties
  apt-get -y install software-properties-common
  apt-add-repository -y ppa:ansible/ansible
  apt-get -y update
  apt-get -y install ansible
}

# Checks if the specified user exists
user_exists() {
  user_name="${1}"
  getent passwd "${user_name}" > /dev/null
}

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf "${cyan}### %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}

# Usage: die MESSAGE
# Prints the specified error message and exits with an error status
die() {
  error "${*}"
  exit 1
}

main "${@}"
