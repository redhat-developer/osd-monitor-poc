FROM centos:7

RUN yum install -y httpd && yum clean all
RUN sed -i -e "s,Listen 80,Listen 8000," /etc/httpd/conf/httpd.conf
RUN sed -i -e "s,logs/error_log,/dev/stderr," /etc/httpd/conf/httpd.conf
RUN sed -i -e "s,logs/access_log,/dev/stdout," /etc/httpd/conf/httpd.conf
EXPOSE 8000

COPY pmwebd_guard.conf /etc/httpd/conf.d/pmwebd_guard.conf
COPY pmwebd_guard.htpasswd /etc/httpd/conf/pmwebd_guard.htpasswd
RUN chmod a+rwX /run/httpd

COPY index.html /var/www/html

VOLUME /var/log/pcp

STOPSIGNAL SIGWINCH

# ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
