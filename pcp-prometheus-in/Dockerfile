FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp pcp-pmda-prometheus && yum clean all

COPY fix-permissions /usr/bin/fix-permissions
COPY pmcd.sh   /pmcd.sh

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /pmcd.sh && \
    /usr/bin/fix-permissions /etc/pcp && \
    /usr/bin/fix-permissions /var/lib/pcp && \
    /usr/bin/fix-permissions /var/log/pcp

ENV PCP_HOSTNAME "osio"
ENV PMCD_PORT "54320"
EXPOSE 54320

ENTRYPOINT [ "/bin/sh", "/pmcd.sh" ]
