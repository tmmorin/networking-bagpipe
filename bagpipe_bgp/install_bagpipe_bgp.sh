#!/bin/bash
#
# Copyright 2014 Orange

set -e

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "*** WARNING: This script must be run as root ***" 1>&2
    exit 1
fi

echo "*** Checking for git ***"
git --version >/dev/null 2>&1 || (echo "You don't have git installed, but setup.py/pbr seems to needs it." && exit 1)

echo "*** Installing BaGPipe BGP ***"

python setup.py install --install-data=/

confFile=/etc/bagpipe-bgp/bgp.conf
oldConf=/etc/bagpipe-bgp/bgp_conf.ini
if [ ! -f $confFile -a -f $oldConf ]; then
    mv -v $oldConf $confFile
fi

if [ ! -f "$confFile" ]; then
    cp /etc/bagpipe-bgp/bgp.conf.template $confFile
fi

[ -d "/var/log/bagpipe-bgp" ] || mkdir /var/log/bagpipe-bgp

case $1 in
    "manual")
        echo -e "\n\n*** WARNING: BaGPipe BGP service must be started manually ***"
        ;;
    "auto"|"")
        echo -e "\n\n*** Starting BaGPipe BGP service ***"
        systemctl enable bagpipe-bgp
        systemctl start bagpipe-bgp
    
        if [ $? -ne 0 ]; then
            echo -e "\nAn error occurred when starting BGP service\n"
            exit 1
        fi
        ;;
    *) echo "Unsupported option! Supported options are 'auto' and 'manual'.";
    exit 1 ;;
esac

echo -e "*** BaGPipe BGP should be ready ! ***\n"