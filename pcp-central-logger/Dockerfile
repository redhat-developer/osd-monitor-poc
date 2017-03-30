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
COPY run-pmmgr.sh ./run-pmmgr.sh 

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /etc/pcp/pmrep && \
    /usr/bin/fix-permissions /etc/pcp/pmmgr && \    
    /usr/bin/fix-permissions /var/log/pcp

# would just touch the file, but want to suppress a silly kubectl warning
# https://github.com/kubernetes/kubernetes/issues/31943
RUN echo --show-all > /etc/pcp/pmmgr/target-kubectl-pod

ENV MALLOC_ARENA_MAX 4

ENV ZABBIX_SERVER    localhost
ENV ZABBIX_PORT      10051
ENV ZABBIX_HOST      pcp
ENV ZABBIX_INTERVAL  1m

VOLUME /var/log/pcp
ENTRYPOINT ["/run-pmmgr.sh"]
