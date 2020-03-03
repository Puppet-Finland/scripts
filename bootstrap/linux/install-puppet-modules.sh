#!/bin/sh
#
# install-puppet-modules.sh
#
# Install Puppet modules from a Puppetfile using r10k installed with Puppet gem

# Exit on any error
set -e

usage() {
    echo "Usage: install-puppet-modules.sh [-f <puppetfile>] [-m <moduledir>] [-h]"
    echo
    echo "Options:"
    echo "    -f    path to Puppetfile (default: /vagrant/Puppetfile)"
    echo "    -m    the directory to install modules to (default: /vagrant/modules)"
    echo "    -h    show this help"
    echo
    exit 2
}

# Default settings
PUPPETFILE="/vagrant/Puppetfile"
MODULEDIR="/vagrant/modules"

while getopts 'p:m:h' arg
do
  case $arg in
    p) PUPPETFILE=$OPTARG ;;
    m) MODULEDIR=$OPTARG ;;
    h) usage ;;
  esac
done

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin


# We install git with puppet resource to avoid having to bake in conditional
# logic (apt, yum, etc) based on the operating system.
install_git() {
    puppet resource package git ensure=present
}

install_r10k() {
    puppet resource package r10k ensure=present provider=puppet_gem
}

install_modules() {
    PUPPETFILE=$1
    MODULEDIR=$2
    r10k puppetfile install -v --puppetfile=$PUPPETFILE --moduledir=$MODULEDIR --force
}


install_git
install_r10k
install_modules $PUPPETFILE $MODULEDIR
