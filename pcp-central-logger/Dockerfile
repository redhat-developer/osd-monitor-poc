FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp-manager && yum clean all

# Install OSO binaries so we can kubectl
RUN yum install -y centos-release-openshift-origin && yum install -y origin-clients && yum clean all

# Denote this as a container environment, for rc scripts
ENV PCP_CONTAINER_IMAGE pcp-central-logger
ENV container docker

COPY fix-permissions /usr/bin/fix-permissions

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /var/log/pcp

# would just touch the file, but want to suppress a silly kubectl warning
# https://github.com/kubernetes/kubernetes/issues/31943
RUN echo --show-all > /etc/pcp/pmmgr/target-kubectl-pod

ENV MALLOC_ARENA_MAX 4

VOLUME /var/log/pcp/pmmgr
ENTRYPOINT ["/usr/libexec/pcp/bin/pmmgr", "-v"]
