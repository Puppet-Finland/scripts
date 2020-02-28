#!/bin/sh
#
# install-restclient.sh
#
# Install ruby rest-client gem using Puppet gem. This allows the
# librenms_device type to work. It is assumed that facter is already available
# at this point. This script is intended to run on existing systems as well as
# fresh provisioned ones.
#
check_build_deps_debian() {
    `dpkg -l build-essential|grep -E '^ii' > /dev/null 2>&1`
    if [ $? -eq 0 ]; then
        export REMOVE_BUILD_DEPS="no"
    fi
}

check_build_deps_centos7() {
    # Check if gcc is installed. If so, do not remove any development packages
    # to avoid accidentally breaking things.
    rpm -qa|grep -E '^gcc-[[:digit:]]' > /dev/null
    if [ $? -eq 0 ]; then
        export REMOVE_BUILD_DEPS="no"
    fi
}

install_debian() {
    apt-get update -o quiet=2
    apt-get -y install build-essential
    $GEM install rest-client
}

install_centos7() {
    yum -y install gcc gcc-c++ make
    $GEM install rest-client
}

remove_devel_packages_debian() {
    # Removing just build-essential is not enough, not even with "apt-get autoremove".
    if [ "${REMOVE_BUILD_DEPS}" = "yes" ]; then
        LSBDISTCODENAME=`$FACTER lsbdistcodename`
        echo $LSBDISTCODENAME
        if [ "$LSBDISTCODENAME" = "bionic" ]; then
            apt-get -y remove libmpc3 libgcc-7-dev libmpx2 linux-libc-dev libfakeroot libc6-dev cpp-7 libalgorithm-diff-perl libalgorithm-merge-perl binutils cpp libitm1 g++ gcc-7-base gcc libcilkrts5 libasan4 libquadmath0 libisl19 build-essential libfile-fcntllock-perl binutils-x86-64-linux-gnu libstdc++-7-dev libtsan0 libubsan0 g++-7 make fakeroot gcc-7 liblsan0 libgomp1 manpages-dev binutils-common libc-dev-bin libbinutils libatomic1 libcc1-0 libdpkg-perl libalgorithm-diff-xs-perl dpkg-dev
        elif [ "$LSBDISTCODENAME" = "xenial" ]; then
            apt-get -y remove libmpc3 libgcc-5-dev libmpx0 linux-libc-dev libfakeroot libc6-dev cpp-5 libalgorithm-diff-perl libalgorithm-merge-perl binutils cpp libitm1 g++ gcc libcilkrts5 libasan2 libquadmath0 libisl15 build-essential libfile-fcntllock-perl libstdc++-5-dev libtsan0 libubsan0 g++-5 make fakeroot gcc-5 liblsan0 libgomp1 manpages-dev libc-dev-bin libcc1-0 libdpkg-perl libalgorithm-diff-xs-perl dpkg-dev
        fi
    fi
}

remove_devel_packages_centos7() {
    if [ "${REMOVE_BUILD_DEPS}" = "yes" ]; then
        yum -y remove gcc gcc-c++ make
    fi
}

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export FACTER=/opt/puppetlabs/puppet/bin/facter
export GEM=/opt/puppetlabs/puppet/bin/gem
export REMOVE_BUILD_DEPS="yes"

# Do not run if rest-client is already installed
if [ -f "/opt/puppetlabs/puppet/bin/restclient" ]; then
    echo "Ruby rest-client gem already installed, not doing anything"
    exit 0
fi

if [ "`$FACTER osfamily`" = "Debian" ]; then
    export DEBIAN_FRONTEND=noninteractive
    export DEBIAN_PRIORITY=critical
    check_build_deps_debian
    install_debian
    remove_devel_packages_debian
elif [ "`$FACTER osfamily`" = "RedHat" ]; then
    check_build_deps_centos7
    install_centos7
    remove_devel_packages_centos7
fi
