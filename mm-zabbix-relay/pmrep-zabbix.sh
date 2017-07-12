#! /bin/sh

# This is a wrapper for pmrep.  We want to send out zabbix data for a
# given incoming $PCP_HOST, while propagating the pmcd.hostname of
# that server to zabbix.  And we want to run multiple copies of this
# in parallel.
#
# We assume a $PCP_HOST env var is set as a hostspec (pcp -h $PCP_HOST).
# We assume the $ZABBIX_SERVER env var is set.
# We assume the $ZABBIX_HOSTNAME env var is set.
# 
if [ -z "$ZABBIX_SERVER" ]; then echo need ZABBIX_SERVER; exit 1; fi
if [ -z "$PCP_HOST" ]; then echo need PCP_HOST; exit 1; fi
if [ -z "$ZABBIX_HOSTNAME" ]; then echo need ZABBIX_HOSTNAME; exit 1; fi

tmpfile=/tmp/zabbix-$ZABBIX_HOSTNAME.conf

(
echo '[options]'
echo zabbix_server = $ZABBIX_SERVER
echo zabbix_host = $ZABBIX_HOSTNAME
echo zabbix_interval = 60s
) > $tmpfile

echo starting pmrep for $PCP_HOST to $ZABBIX_SERVER

# No need to delete this configuration file; there won't be many
exec pmrep -c $tmpfile -o zabbix $@
