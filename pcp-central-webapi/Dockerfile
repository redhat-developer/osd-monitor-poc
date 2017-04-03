FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp-webapi 'pcp-webapp-*' && yum clean all

# XXXX also need httpd proxy oauth thingie

# Expose pmwebd's main port on the host interface
EXPOSE 44323

VOLUME /var/log/pcp

ENV MALLOC_ARENA_MAX 1

# -M8?

ENTRYPOINT ["/usr/libexec/pcp/bin/pmwebd", "-v", "-v", "-G", "-X", "-R", "/usr/share/pcp/webapps", "-A", "/var/log/pcp/pmmgr", "-i", "15", "-P", "-M8"]

