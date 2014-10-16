#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Run all BATS test files in the current directory.
#
# The script installs BATS if needed. It's best to put ${bats_install_dir} in
# your .gitignore.

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#{{{ Variables

color_defs="${HOME}/.bash.d/colors.sh"

test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bats_repo_url="https://github.com/sstephenson/bats.git"
bats_install_dir="${test_dir}/bats"
bats="${bats_install_dir}/libexec/bats"

test_file_pattern="*.bats"

#}}}
# Script proper

# Load color definitions, if available
if [[ -f "${color_defs}" ]]; then
  source "${color_defs}"
else
  Blue=
  Yellow=
  Reset=
fi

# Install BATS if needed
if [[ ! -d "${bats_install_dir}" ]]; then
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
  #${bats} ${test_case}
done
