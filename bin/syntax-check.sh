#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Run a syntax check on ansible/site.yml

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#{{{ Variables

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#}}}

# Script proper

${script_dir}/playbook.sh ${script_dir}/../ansible/site.yml --syntax-check

