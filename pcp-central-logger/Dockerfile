FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp pcp-manager pcp-debuginfo pcp-export-pcp2zabbix valgrind pcp-system-tools && yum clean all

# Install OSO binaries so we can kubectl
RUN yum install -y centos-release-openshift-origin && yum install -y origin-clients && yum clean all

COPY fix-permissions /usr/bin/fix-permissions
COPY pmmgr+pmcd.sh   /pmmgr+pmcd.sh
COPY pminfo-sleep.sh /pminfo-sleep.sh

ADD pmmgr-node /etc/pcp/pmmgr-node
ADD pmmgr-pod /etc/pcp/pmmgr-pod
ADD pmmgr-db /etc/pcp/pmmgr-db

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /etc/pcp && \
    /usr/bin/fix-permissions /var/lib/pcp && \  
    /usr/bin/fix-permissions /var/log/pcp

ENV MALLOC_ARENA_MAX 1
ENV ZABBIX_SERVER    localhost

ENV VALGRIND ""
# ENV VALGRIND /usr/bin/valgrind

VOLUME /var/log/pcp
ENTRYPOINT [ "/bin/sh", "/pmmgr+pmcd.sh" ]
