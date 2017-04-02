FROM centos:7

# Install pcp - collection basics
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp && yum clean all

COPY fix-permissions /usr/bin/fix-permissions
COPY ./run-pmcd.sh /run-pmcd.sh
RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /etc/pcp && \
    /bin/mkdir /var/run/pcp && \
    /usr/bin/fix-permissions /var/run/pcp && \
    /usr/bin/fix-permissions /var/lib/pcp && \
    /usr/bin/fix-permissions /var/log/pcp
# Expose pmcd's main port on the host interface
EXPOSE 44321

ENV PCP_HOSTNAME node-deadbeef
ENTRYPOINT ["/run-pmcd.sh"]
