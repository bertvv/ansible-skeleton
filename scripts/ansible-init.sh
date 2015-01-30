#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Initialise an Ansible project, based on 
# https://github.com/bertvv/ansible-skeleton/

set -u # abort on unbound variable

#{{{ Variables

#}}}
#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} PROJECT_NAME [ROLE]...
  Initialises a Vagrant+Ansible project based on
  https://github.com/bertvv/ansible-skeleton
  and optionally, installs the specified roles from Ansible Galaxy
_EOF_
}

install_role() {
  # First, try to install from Ansible Galaxy directly
  ansible-galaxy install -p ansible/roles "${1}"

  if [ "$?" -ne "0" ]; then
    echo " ## This does not seem to be an Ansible role. Trying Github"
    user=${1%%\.*}
    role=${1##*\.}
    rolename=${role##ansible-}
    git_url="https://github.com/${user}/${role}.git"
    echo " ## => ${git_url}"
    git clone "${git_url}" "ansible/roles/${user}.${rolename}"
  fi
}

#}}}
#{{{ Command line parsing

if [ "$#" -lt "1" ]; then
    echo "Expected at least 1 argument, got $#" >&2
    usage
    exit 2
fi

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  usage
  exit 0
fi

project="$1"

if [ -d "${project}" ]; then
  echo "Project directory ${project} already exists. Bailing out." >&2
  exit 1
fi

shift

#}}}
# Script proper

wget https://github.com/bertvv/ansible-skeleton/archive/master.zip
unzip master.zip
rm master.zip

mv ansible-skeleton-master "${project}"
git init "${project}"
cd "${project}"
git add .
git commit --message "Initial commit, Ansible skeleton"

for role in "${@}"; do
  install_role "${role}"
done

