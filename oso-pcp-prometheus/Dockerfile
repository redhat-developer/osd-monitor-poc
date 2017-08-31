FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp-webapi && yum clean all

# Expose pmwebd's main port on the host interface
EXPOSE 44323
ENV MALLOC_ARENA_MAX 1
ENTRYPOINT ["/usr/libexec/pcp/bin/pmwebd", "-v", "-v", "-h", "localhost"]
