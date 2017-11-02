FROM centos:7

RUN yum install -y httpd curl && yum clean all
RUN sed -i -e "s,Listen 80,Listen 8001," /etc/httpd/conf/httpd.conf
RUN sed -i -e "s,logs/error_log,/dev/stderr," /etc/httpd/conf/httpd.conf
RUN sed -i -e "s,logs/access_log,/dev/stdout," /etc/httpd/conf/httpd.conf
EXPOSE 8001

COPY pmwebd_guard.conf /etc/httpd/conf.d/pmwebd_guard.conf

# the htpasswd file may be periodically replaced during run
RUN touch                  /etc/httpd/conf/pmwebd_guard.htpasswd
RUN chmod a+rwX            /etc/httpd/conf/pmwebd_guard.htpasswd

RUN chmod a+rwX /run/httpd

COPY webapi_guard_start.sh /webapi_guard_start.sh

# where to fetch htpasswd updates from
ENV OSIO_NAMESPACE ""
ENV OSIO_ACL_SERVER ""

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/bin/sh", "/webapi_guard_start.sh"]
