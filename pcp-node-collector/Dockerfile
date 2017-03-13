FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp && yum clean all

# Denote this as a container environment, for rc scripts
ENV PCP_CONTAINER_IMAGE pcp-node-collector
ENV container docker

# Setup pmcd to run in unprivileged mode of operation
RUN . /etc/pcp.conf; \
    rm -f $PCP_SYSCONFIG_DIR/pmcd; \
    echo "PMCD_ROOT_AGENT=0" >> $PCP_SYSCONFIG_DIR/pmcd

# Configure pmcd with a minimal set of DSO agents
RUN . /etc/pcp.conf; \
    rm -f $PCP_PMCDCONF_PATH; \
    echo "# Name  ID  IPC  IPC Params  File/Cmd" >> $PCP_PMCDCONF_PATH; \
    echo "pmcd     2  dso  pmcd_init   $PCP_PMDAS_DIR/pmcd/pmda_pmcd.so"   >> $PCP_PMCDCONF_PATH; \
    echo "proc     3  dso  proc_init   $PCP_PMDAS_DIR/proc/pmda_proc.so"   >> $PCP_PMCDCONF_PATH; \
    echo "linux   60  dso  linux_init  $PCP_PMDAS_DIR/linux/pmda_linux.so" >> $PCP_PMCDCONF_PATH; \
    echo "mmv     70  dso  mmv_init    $PCP_PMDAS_DIR/mmv/pmda_mmv.so"     >> $PCP_PMCDCONF_PATH; \
    rm -f $PCP_VAR_DIR/pmns/root_xfs $PCP_VAR_DIR/pmns/root_jbd2 $PCP_VAR_DIR/pmns/root_root; \
    touch $PCP_VAR_DIR/pmns/.NeedRebuild

# Disable service advertising - no avahi support in the container
# (dodges warnings from pmcd attempting to connect during startup)
RUN . /etc/pcp.conf && echo "-A" >> $PCP_PMCDOPTIONS_PATH

# allow unauthenticated access to proc.* metrics (default is false)
ENV PROC_ACCESS 1

# Expose pmcd's main port on the host interface
EXPOSE 44321

# The command to run - in this case the pmcd service script. When this command
# exits, then the container exits. This is the default command and parameters
# and can be overridden by passing additional parameters to docker run.
ENV PATH /usr/share/pcp/lib:/usr/libexec/pcp/bin:$PATH
ENTRYPOINT ["pmcd"]
CMD ["start"]
