#! /bin/bash -e

: "${PCP_HOSTNAME:=`hostname`}"

# Set up internal pmcd

# Denote this as a container environment, for rc scripts
export PCP_CONTAINER_IMAGE=pcp-sidecar-collector
export container=docker

# Setup pmcd to run in unprivileged mode of operation
. /etc/pcp.conf;
rm -f $PCP_SYSCONFIG_DIR/pmcd;
echo "PMCD_ROOT_AGENT=0" >> $PCP_SYSCONFIG_DIR/pmcd

# Configure pmcd with a minimal set of DSO agents
rm -f $PCP_PMCDCONF_PATH;
echo "# Name  ID  IPC  IPC Params  File/Cmd" >> $PCP_PMCDCONF_PATH;
echo "pmcd     2  dso  pmcd_init   $PCP_PMDAS_DIR/pmcd/pmda_pmcd.so"   >> $PCP_PMCDCONF_PATH;
echo "proc     3  dso  proc_init   $PCP_PMDAS_DIR/proc/pmda_proc.so"   >> $PCP_PMCDCONF_PATH;
echo "linux   60  dso  linux_init  $PCP_PMDAS_DIR/linux/pmda_linux.so" >> $PCP_PMCDCONF_PATH;
rm -f $PCP_VAR_DIR/pmns/root_xfs $PCP_VAR_DIR/pmns/root_jbd2 $PCP_VAR_DIR/pmns/root_root;
    touch $PCP_VAR_DIR/pmns/.NeedRebuild

# Disable service advertising - no avahi support in the container
# (dodges warnings from pmcd attempting to connect during startup)
echo "-A" >> $PCP_PMCDOPTIONS_PATH
echo "-H $PCP_HOSTNAME" >> $PCP_PMCDOPTIONS_PATH

# allow unauthenticated access to proc.* metrics (default is false)
export PROC_ACCESS=1

# override $PCP_DIR so as to suppress the uid=0 assertion in the rc.pmcd script
export PCP_DIR=/

# start pmcd in the background
/usr/share/pcp/lib/pmcd start &


