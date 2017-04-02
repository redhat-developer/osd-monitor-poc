FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp-manager pcp-system-tools && yum clean all

# Install OSO binaries so we can kubectl
RUN yum install -y centos-release-openshift-origin && yum install -y origin-clients && yum clean all

# Denote this as a container environment, for rc scripts
ENV PCP_CONTAINER_IMAGE pcp-central-logger
ENV container docker

COPY fix-permissions /usr/bin/fix-permissions
COPY pmrep-zabbix.sh /pmrep-zabbix.sh

ADD pmmgr-node /etc/pcp/pmmgr-node
ADD pmmgr-pod /etc/pcp/pmmgr-pod

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /var/log/pcp

ENV MALLOC_ARENA_MAX 4

ENV ZABBIX_SERVER    localhost

VOLUME /var/log/pcp
ENTRYPOINT ["/usr/libexec/pcp/bin/pmmgr", "-v", "-c", "/etc/pcp/pmmgr-node", "-c", "/etc/pcp/pmmgr-pod"]
