#!/bin/bash
######################################################################
##
## Variables in the script:
##   REQUIRED
##     - VPN_DNS_PREFIX
##     - DNS_ZONE
##   - VPN_PROTO
##   - VPN_PORT
##   - HTTPS_PORT
##   - ALLOW_UDP
##
######################################################################

echo "Red Hat Enterprise Linux Server release 6.3 (Santiago)" > /etc/redhat-release
rpm -ivh http://swupdate.openvpn.org/as/openvpn-as-2.0.25-CentOS6.x86_64.rpm

cd /usr/local/openvpn_as/etc/db

# http://sites.inka.de/~bigred/devel/tcp-tcp.html

if [ -z "${VPN_PROTO:-}" ]; then
    VPN_PROTO="udp"
fi

PORT_SHARE_ENABLE=false
if [ "$VPN_PROTO" == "tcp" ]
    PORT_SHARE_ENABLE=true
fi

if [ -z "${VPN_PORT:-}" ]; then
    VPN_PORT=1199
fi

if [ -z "${HTTPS_PORT:-}" ]; then
    HTTPS_PORT=443
fi

service openvpnas stop

sqlite3 config.db "UPDATE config SET value='$VPN_DNS_PREFIX.$DNS_ZONE' WHERE name='host.name'";

sqlite3 config.db "UPDATE config SET value='$VPN_PROTO' WHERE name='vpn.daemon.0.listen.protocol'";
sqlite3 config.db "UPDATE config SET value='$VPN_PORT' WHERE name='vpn.daemon.0.listen.port'";
sqlite3 config.db "UPDATE config SET value='$VPN_PORT' WHERE name='vpn.server.daemon.tcp.port'";
sqlite3 config.db "UPDATE config SET value='false' WHERE name='vpn.server.daemon.enable'";

sqlite3 config.db "UPDATE config SET value='$HTTPS_PORT' WHERE name='admin_ui.https.port'";
sqlite3 config.db "UPDATE config SET value='$HTTPS_PORT' WHERE name='cs.https.port'";
sqlite3 config.db "UPDATE config SET value='$PORT_SHARE_ENABLE' WHERE name='vpn.server.port_share.enable'";


service openvpnas start
