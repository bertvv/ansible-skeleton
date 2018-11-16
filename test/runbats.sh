#! /usr/bin/env bash
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

bats_archive="v1.1.0.tar.gz"
bats_url="https://github.com/bats-core/bats-core/archive/${bats_archive}"
bats_install_dir="/opt"
bats="${bats_install_dir}/bats/libexec/bats"

test_file_pattern="*.bats"

# color definitions
Blue='\e[0;34m'
Yellow='\e[0;33m'
Reset='\e[0m'

#}}}
#{{{ Functions

# Usage: install_bats_if_needed
install_bats_if_needed() {
  pushd "${bats_install_dir}" > /dev/null
  if [[ ! -d "${bats_install_dir}/bats" ]]; then
    wget "${bats_url}"
    tar xf "${bats_archive}"
    mv bats-* bats
    rm "${bats_archive}"
  fi
  popd > /dev/null
}

# find_tests DIR [MAX_DEPTH]
find_tests() {
  local max_depth=""
  if [ "$#" -eq "2" ]; then
    max_depth="-maxdepth $2"
  fi

  local tests
  tests=$(find "$1" "${max_depth}" -type f -name "${test_file_pattern}" -printf '%p\n' 2> /dev/null)

  echo "${tests}"
}
#}}}
# Script proper

install_bats_if_needed

# List all test cases (i.e. files in the test dir matching the test file
# pattern)
# Tests to be run on all hosts
global_tests=$(find_tests "${test_dir}" 1)

# Tests for individual hosts
host_tests=$(find_tests "${test_dir}/${HOSTNAME}")

# Loop over test files
for test_case in ${global_tests} ${host_tests}; do
  echo -e "${Blue}Running test ${Yellow}${test_case}${Reset}"
  ${bats} "${test_case}"
done
