#!/usr/bin/env bash
set -ex
cd $(dirname "$(realpath "$0")")

header() {
  cat <<EOF
# DO NOT EDIT THIS FILE!!!

# This file is automatically generated by mk_build_yml.sh
# Edit build.yml.in instead and run mk_build_yml.sh to update.

# Forks of mathlib and other projects should be able to use build_fork.yml directly
EOF
}

build_yml() {
  header
  cat <<EOF
# The jobs in this file run on self-hosted workers and will not be run from external forks

on:
  push:
    branches-ignore:
      # ignore tmp branches used by bors
      - 'staging.tmp*'
      - 'trying.tmp*'
      - 'staging*.tmp'
      - 'nolints'
      # do not build lean-x.y.z branch used by leanpkg
      - 'lean-3.*'
      # ignore staging branch used by bors, this is handled by bors.yml
      - 'staging'

name: continuous integration
EOF
  include 1 pr == "" ubuntu-latest
}

bors_yml() {
  header
  cat <<EOF
# The jobs in this file run on self-hosted workers and will not be run from external forks

on:
  push:
    branches:
      - staging

name: continuous integration (staging)
EOF
  include 1 bors == "" bors
}

build_fork_yml() {
  header
  cat <<EOF
# The jobs in this file run on GitHub-hosted workers and will only be run from external forks

on:
  push:
    branches-ignore:
      # ignore tmp branches used by bors
      - 'staging.tmp*'
      - 'trying.tmp*'
      - 'staging*.tmp'
      - 'nolints'
      # do not build lean-x.y.z branch used by leanpkg
      - 'lean-3.*'

name: continuous integration (mathlib forks)
EOF
  include 0 ubuntu-latest != " (fork)" ubuntu-latest
}

include() {
  sed "
    s/IS_SELF_HOSTED/$1/g;
    s/RUNS_ON/$2/g;
    s/MAIN_OR_FORK/$3/g;
    s/JOB_NAME/$4/g;
    s/STYLE_LINT_RUNNER/$5/g;
  " build.yml.in
}

build_yml > build.yml
bors_yml > bors.yml
build_fork_yml > build_fork.yml