FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp pcp-manager pcp-system-tools && yum clean all

COPY fix-permissions /usr/bin/fix-permissions
COPY pmrep-zabbix.sh /pmrep-zabbix.sh

ADD pmmgr-mm /etc/pcp/pmmgr-mm

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /etc/pcp && \
    /usr/bin/fix-permissions /var/lib/pcp && \  
    /usr/bin/fix-permissions /var/log/pcp

ENV MALLOC_ARENA_MAX 1
ENV ZABBIX_SERVER localhost
ENV ZABBIX_HOSTNAME localhost
ENV PCP_METRICS "cgroup.memory.usage network.interface.in.bytes network.interface.out.bytes cgroup.cpuacct.usage"

VOLUME /var/log/pcp
ENTRYPOINT [ "/usr/libexec/pcp/bin/pmmgr", "-c", "/etc/pcp/pmmgr-mm", "-v" ]
