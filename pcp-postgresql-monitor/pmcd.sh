#! /bin/bash -e

: "${PCP_HOSTNAME:=`uname -n`}"

# Set up internal pmcd

# Setup pmcd to run in unprivileged mode of operation
. /etc/pcp.conf

# Configure pmcd with a minimal set of DSO agents
rm -f $PCP_PMCDCONF_PATH; # start empty
echo "# Name  ID  IPC  IPC Params  File/Cmd" >> $PCP_PMCDCONF_PATH;
echo "pmcd     2  dso  pmcd_init   $PCP_PMDAS_DIR/pmcd/pmda_pmcd.so"   >> $PCP_PMCDCONF_PATH;
echo "proc     3  dso  proc_init   $PCP_PMDAS_DIR/proc/pmda_proc.so"   >> $PCP_PMCDCONF_PATH;
echo "linux   60  dso  linux_init  $PCP_PMDAS_DIR/linux/pmda_linux.so" >> $PCP_PMCDCONF_PATH;
echo "postgresql      110     pipe    binary          perl /var/lib/pcp/pmdas/postgresql/pmdapostgresql.pl" >> $PCP_PMCDCONF_PATH;
#                                                                                                         ^^^^^
#                                                                           for stderr logging, need also: -l -, but no perl/pmda support yet

rm -f $PCP_VAR_DIR/pmns/root_xfs $PCP_VAR_DIR/pmns/root_jbd2 $PCP_VAR_DIR/pmns/root_root $PCP_VAR_DIR/pmns/root
echo 'postgresql	110:*:*' > $PCP_VAR_DIR/pmns/postgresql
touch $PCP_VAR_DIR/pmns/.NeedRebuild

# allow unauthenticated access to proc.* metrics (default is false)
export PROC_ACCESS=1
export PMCD_ROOT_AGENT=0

# NB: we can't use the rc.pmcd script.  It assumes that it's run as root.
cd $PCP_VAR_DIR/pmns
./Rebuild
$PCP_BINADM_DIR/pmnsadd -n root postgresql

cd $PCP_PMDAS_DIR/postgresql
conf=postgresql.conf
echo '$database="dbi:Pg:dbname='$DB_DB';host='$DB_HOSTNAME';port='$DB_PORT'";' > $conf
echo '$username="'$DB_USER'";' >> $conf
echo '$password='"'"$DB_PASSWORD"'"';' >> $conf # protect $punctuation within
echo '$os_user="'`whoami`'";' >> $conf

cd $PCP_LOG_DIR
exec $PCP_BINADM_DIR/pmcd -p $PMCD_PORT -l - -f -A -H $PCP_HOSTNAME
