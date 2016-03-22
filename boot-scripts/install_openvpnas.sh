#!/bin/bash

echo "Red Hat Enterprise Linux Server release 6.3 (Santiago)" > /etc/redhat-release
rpm -ivh http://swupdate.openvpn.org/as/openvpn-as-2.0.25-CentOS6.x86_64.rpm

/usr/local/openvpn_as/bin/ovpn-init < ../files/ovpn-init.stdin
