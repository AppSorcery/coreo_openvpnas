#!/bin/bash

wget http://swupdate.openvpn.org/as/openvpn-as-2.0.25-CentOS6.x86_64.rpm
sudo rpm -i openvpn-as-2.0.5-CentOS6.x86_64.rpm
sed -i -e "s/openvpnas_gen_init/openvpnas_gen_init --distro redhat/g" /usr/local/openvpn_as/scripts/openvpnas_gen_init/_ovpn_init
