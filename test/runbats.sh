#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Run BATS test files in the current directory, and the ones in the subdirectory
# matching the host name.
#
# The script installs BATS if needed. It's best to put ${bats_install_dir} in
# your .gitignore.

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable

#{{{ Variables

test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bats_repo_url="https://github.com/sstephenson/bats.git"
bats_install_dir="${test_dir}/bats"
bats="${bats_install_dir}/libexec/bats"

test_file_pattern="*.bats"

# color definitions
Blue='\e[0;34m'
Yellow='\e[0;33m'
Reset='\e[0m'

#}}}
# Script proper

# Install BATS if needed
if [ ! -d "${bats_install_dir}" ]; then
  git clone "${bats_repo_url}" "${bats_install_dir}"
  rm -rf "${bats_install_dir}/.git*"
fi

# List all test cases (i.e. files in the test dir matching the test file
# pattern)
# Tests to be run on all hosts
global_tests=$(find "${test_dir}" -maxdepth 1 -type f -name "${test_file_pattern}" -printf "%p\n")
# Tests for individual hosts
host_tests=$(find "${test_dir}/${HOSTNAME}" -type f -name "${test_file_pattern}" -printf "%p\n")

# Loop over test files
for test_case in ${global_tests} ${host_tests}; do
  echo -e "${Blue}Running test ${Yellow}${test_case}${Reset}"
  ${bats} "${test_case}"
done
