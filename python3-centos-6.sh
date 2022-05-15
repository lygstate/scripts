#!/bin/bash
#
# This script setups Python 3.10 alternate installation
# on CentOS 6
# Usage: wget -O python3-centos-6.sh https://raw.githubusercontent.com/vinodpandey/scripts/master/python3-centos-6.sh
# chmod +x python3-centos-6.sh
# ./python3-centos-6.sh

# Format inspired from https://github.com/getredash/redash/blob/master/setup/ubuntu/bootstrap.sh
# License: https://github.com/getredash/redash/blob/master/LICENSE

DIR=/tmp
VERSION=3.10.4
URL="https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz"
TARBALL=/tmp/Python-${VERSION}.tgz

cd $DIR

verify_root() {
    # Verify running as root:
    if [ "$(id -u)" != "0" ]; then
        if [ $# -ne 0 ]; then
            echo "Failed running with sudo. Exiting." 1>&2
            exit 1
        fi
        echo "This script must be run as root. Trying to run with sudo."
        sudo bash "$0" --with-sudo
        exit 0
    fi
}

check_python_version() {
    if [[ $(/usr/local/bin/python3.10 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))') == 3.10.* ]]; then
    	SYS_VERSION=$(/usr/local/bin/python3.10 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
    	echo Python $SYS_VERSION already installed
    	exit 1
    fi
}

install_system_packages() {
    yum install -y zlib-devel bzip2-devel libffi-devel
}

install_openssl() {
    # https://bugs.python.org/issue43466
    rm -rf openssl-1.1.1n
    if [[ ! -f "openssl-1.1.1n.tar.gz" ]]; then
        wget --no-check-certificate https://www.openssl.org/source/old/1.1.1/openssl-1.1.1n.tar.gz -O openssl-1.1.1n.tar.gz
    fi
    tar xf openssl-1.1.1n.tar.gz && \
    pushd openssl-1.1.1n && \
        ./config --prefix=/opt/openssl \
        --openssldir=$(find /etc/ -name openssl.cnf -printf "%h" 2>/dev/null) &&
    make -j$(nproc) && make install_sw && popd
}

extract_python_source() {
    if [[ ! -f "$TARBALL" ]]; then
        wget --no-check-certificate "$URL" -O "$TARBALL"
    fi
    rm -rf Python-${VERSION}
    tar -C "$DIR" -xvf "$TARBALL"
}
 
install_python() {
    cd Python-${VERSION}
    ./configure --enable-optimizations \
        --with-openssl=/opt/openssl \
        --prefix=/usr \
        --with-openssl-rpath=auto
    make -j$(nproc) altinstall
    # https://stackoverflow.com/questions/51201459/python-3-7-install-not-working-on-opensuse-leap-42-3?rq=1
    rm -f /usr/lib/python3.10/lib-dynload
    ln -s /usr/lib64/python3.10/lib-dynload/ /usr/lib/python3.10/lib-dynload
    python3.10 -m pip install --upgrade pip setuptools
}

verify_root
check_python_version
install_system_packages
install_openssl
extract_python_source
install_python

