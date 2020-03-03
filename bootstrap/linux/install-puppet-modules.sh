#!/bin/sh
#
# install-puppet-modules.sh
#
# Install Puppet modules from a Puppetfile using r10k installed with Puppet gem

# Exit on any error
set -e

usage() {
    echo "Usage: install-puppet-modules.sh [-n <modulename>] [-f <puppetfile>] [-r <moduleroot>] [-m <moduledir>] [-h]"
    echo
    echo "Options:"
    echo "    -n    module for which these dependencies are installed (no default value)"
    echo "    -f    path to Puppetfile (default: /vagrant/Puppetfile)"
    echo "    -r    path to module root (default: /vagrant)"
    echo "    -m    the directory to install modules to (default: /vagrant/modules)"
    echo "    -h    show this help"
    echo
    exit 2
}

# Default settings suitable for most Vagrant environments
MODULENAME=""
PUPPETFILE="/vagrant/Puppetfile"
MODULEROOT="/vagrant"
MODULEDIR="/vagrant/modules"

while getopts 'n:p:r:m:h' arg
do
  case $arg in
    n) MODULENAME=$OPTARG ;;
    p) PUPPETFILE=$OPTARG ;;
    r) MODULEROOT=$OPTARG ;;
    m) MODULEDIR=$OPTARG ;;
    h) usage ;;
  esac
done

if [ "$MODULENAME" = "" ]; then
    echo "ERROR: root module name must be given with -n <name>!"
    exit 1
fi

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

add_root_module_link() {
    MODULEROOT=$1
    MODULENAME=$2
    ln -s $MODULEROOT $MODULEDIR/$MODULENAME
}

install_git
install_r10k
install_modules $PUPPETFILE $MODULEDIR
add_root_module_link $MODULEROOT $MODULENAME
