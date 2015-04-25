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

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Variables
dependencies=$(grep '    - .*\..*' ansible/site.yml | cut -c7-)
roles_path=ansible/roles
#}}}

# Script proper
for dep in ${dependencies}; do
  if [ ! -d "${roles_path}/${dep}" ]; then
    ansible-galaxy install -p "${roles_path}" "${dep}"
  else
    echo "+ Skipping ${dep}, seems to be installed already"
  fi
done

