#!/bin/bash

echo "Red Hat Enterprise Linux Server release 6.3 (Santiago)" > /etc/redhat-release
wget http://swupdate.openvpn.org/as/openvpn-as-2.0.25-CentOS6.x86_64.rpm
rpm -i ./openvpn-as-2.0.5-CentOS6.x86_64.rpm
