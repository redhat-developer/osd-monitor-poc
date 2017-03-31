#! /bin/bash -e

: "${ZABBIX_SERVER:=localhost}"
: "${ZABBIX_PORT:=10051}"
: "${ZABBIX_HOST:=pcp}"
: "${ZABBIX_INTERVAL:=1m}"

. /etc/pcp.conf

# Configure pmrep's zabbix output
conf=$PCP_SYSCONF_DIR/pmrep/pmrep.conf
(
echo
echo '[options]'
echo 'zabbix_server = '$ZABBIX_SERVER
echo 'zabbix_port = '$ZABBIX_PORT
echo 'zabbix_host = '$ZABBIX_HOST
echo 'zabbix_interval = '$ZABBIX_INTERVAL
) >> $conf

cd $PCP_LOG_DIR
exec /usr/libexec/pcp/bin/pmmgr -v
