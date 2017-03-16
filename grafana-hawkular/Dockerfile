FROM centos:7

# Install pcp - collection basics
# would prefer only pmcd, and not the /bin/pm*tools etc.
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp && yum clean all

ENV GRAFANA_VERSION 4.1.2-1486989747

# Install grafana
RUN yum install -y https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VERSION}.x86_64.rpm && \
    yum install -y unzip && \
    yum clean all

# Install hawkular-grafana-datasource latest github release
RUN curl -L https://github.com/hawkular/hawkular-grafana-datasource/archive/release.zip -o hawkular-grafana-datasource-release.zip && \
    unzip hawkular-grafana-datasource-release.zip && \
    rm hawkular-grafana-datasource-release.zip && \
    mkdir -p /var/lib/grafana/plugins/hawkular-datasource && \
    mv hawkular-grafana-datasource-release /var/lib/grafana/plugins/hawkular-datasource

# Fix permissions so will run on OCP under "restricted" SCC
COPY ./run.sh /run.sh
COPY fix-permissions /usr/bin/fix-permissions

RUN chmod +x /usr/bin/fix-permissions && \
    /usr/bin/fix-permissions /run.sh && \
    /usr/bin/fix-permissions /var/lib/grafana && \
    /usr/bin/fix-permissions /var/log/grafana && \
    /usr/bin/fix-permissions /etc/grafana

EXPOSE 3000

COPY ./run-pmcd.sh /run-pmcd.sh
RUN /usr/bin/fix-permissions /etc/pcp && \
    /usr/bin/fix-permissions /var/log/pcp
EXPOSE 44321

# some configuration secrets are mandatory - pass them with # docker run -e | oc run --env
#
# ENV GF_SECURITY_ADMIN_PASSWORD something
# ENV GF_DATASOURCE_URL https://foo.bar/hawkular/metrics
# ENV GF_DATASOURCE_TENANT foo
# ENV GF_DATASOURCE_TOKEN bar
# ENV PCP_HOSTNAME pod-65-foobar

ENTRYPOINT ["/run.sh"]
