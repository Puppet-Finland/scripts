#!/bin/sh
#
# This script automates the installation of PuppetDB certificates on your own
# laptop/workstation. It should work ok on any Linux distribution.
#
# Assumptions:
#
# - static-inventory.yaml contains group "puppetmaster" that contains the puppetmaster
# - bolt is installed and configured
# - SSH is configured to use key authentication
# - remote user has sudo privileges on the puppetmaster
#
set -e

usage() {
    cat << EOF
    ./get_puppetdb_certs.sh <remote_username> <remote_sudo_password> <project>"
    
    Example: ./get_puppetdb_certs.sh john secret123 acme_inc"
EOF
}

# Sanity checks
if ! which bolt > /dev/null 2>&1; then
    echo "ERROR: this script requires Puppet Bolt ("bolt") to be in PATH to work!"
    exit 1
fi

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]; then
    usage
    exit 1
fi

USERNAME="$1"
SUDO_PASSWORD="$2"
PROJECT="$3"
CERTNAME="${USERNAME}_bolt"

# We need to be in the project directory (=control repository root) for Bolt
# commands to run properly
cd `dirname "$0"`/..
WD=`pwd`

# Restore inventory.yaml if a previous run had failed, leaving it in the wrong place
test -f inventory.yaml.moved-temporarily && mv inventory.yaml.moved-temporarily inventory.yaml

# Move away inventory.yaml - it will get autoloaded no matter what and can't succeed
# until PuppetDB certificates have been configured.
mv inventory.yaml inventory.yaml.moved-temporarily

bolt command run "/opt/puppetlabs/bin/puppetserver ca generate --certname ${CERTNAME}" -u "$USERNAME" -i static-inventory.yaml -t puppetmaster --run-as root --sudo-password "$SUDO_PASSWORD"
bolt command run "tar -C /etc/puppetlabs/puppet/ssl -cf /home/${USERNAME}/puppetdb-certs.tar private_keys/${CERTNAME}.pem certs/${CERTNAME}.pem certs/ca.pem" -u "$USERNAME" -i static-inventory.yaml -t puppetmaster --run-as root --sudo-password "$SUDO_PASSWORD"

mkdir -p ~/.puppetlabs/etc/bolt/openvpn/ssl
bolt file download "/home/$USERNAME/puppetdb-certs.tar" ~/.puppetlabs/etc/bolt/"$PROJECT"/ssl -u "$USERNAME" -i static-inventory.yaml -t puppetmaster

bolt command run "rm -f /home/$USERNAME/puppetdb-certs.tar" -u "$USERNAME" -i static-inventory.yaml -t puppetmaster --run-as root --sudo-password "$SUDO_PASSWORD"

cd ~/.puppetlabs/etc/bolt/"$PROJECT"/ssl
tar -xf puppet*/puppetdb-certs.tar
rm -rf puppet*
cd certs
mv "$CERTNAME.pem" cert.pem
cd ../private_keys
mv "$CERTNAME.pem" key.pem
cd "$WD"
mv inventory.yaml.moved-temporarily inventory.yaml
