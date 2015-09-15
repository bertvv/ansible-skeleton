#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Install role dependencies
#
# ansible/roles contains all roles used by nodes managed in this
# project. Generic roles from Ansible Galaxy are stored in a directory
# with name "user.rolename". These directories are ignored by
# .gitignore and should be installed after cloning the project
# repository. That's what this script does...
#
# The script will search ansible/site.yml for roles assigned to hosts
# with names in the "user.role" form and will try to install them all.
# If possible, it will use Ansible Galaxy (on Linux), but if this is not
# available (e.g. on Windows), it will use Git to clone the latest version.
#
# Remark that this is a very crude technique and especially the Git fallback
# is very brittle. It will download HEAD, and not necessarily the latest
# release of the role. Additionally, the name of the repository is guessed,
# but if it does not exist, the script will fail.
#
# Using ansible-galaxy and a dependencies.yml file is the best method, but
# unavailable on Windows. This script is an effort to have a working
# alternative.

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Variables
dependencies=$(grep '    - .*\..*' ansible/site.yml | cut -c7- | sort -u)
roles_path=ansible/roles
#}}}

#{{{ Functions

# Usage: select_installer
# Sets the variable `installer`, the function to use when installing roles
# Try to use ansible-galaxy when it is available, and fall back to `git clone`
# when it is not.
select_installer() {
  if which ansible-galaxy > /dev/null 2>&1 ; then
    installer=install_role_galaxy
  else
    installer=install_role_git
  fi
}

# Usage: is_valid_url URL
# returns 0 if the URL is valid, 22 otherwise
is_valid_url() {
  local url=$1

  curl --silent --fail "${url}" > /dev/null
}

# Usage: install_role_galaxy OWNER ROLE
install_role_galaxy() {
  local owner=$1
  local role=$2
  ansible-galaxy install --roles-path="${roles_path}" \
    "${owner}.${role}"
}

# Usage: install_role_git OWNER ROLE
install_role_git() {
  local owner=$1
  local role=$2

  # First try https://github.com/OWNER/ansible-role-ROLE
  local repo="https://github.com/${owner}/ansible-role-${role}"

  if is_valid_url "${repo}"; then
    git clone "${repo}" "${roles_path}/${owner}.${role}"
  else
  # If that fails, try https://github.com/OWNER/ansible-ROLE
    git clone "https://github.com/${owner}/ansible-${role}" \
      "${roles_path}/${owner}.${role}"
  fi
}
#}}}

# Script proper

select_installer

for dep in ${dependencies}; do
  owner=${dep%%.*}
  role=${dep##*.}

  if [[ ! -d "${roles_path}/${dep}" ]]; then
    ${installer} "${owner}" "${role}"
  else
    echo "+ Skipping ${dep}, seems to be installed already"
  fi
done

