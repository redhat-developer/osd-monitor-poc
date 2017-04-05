FROM centos:7

RUN yum install -y httpd && yum clean all
EXPOSE 80

COPY pmwebd_guard.conf /etc/httpd/conf.d/pmwebd_guard.conf
COPY pmwebd_guard.htpasswd /etc/httpd/conf/pmwebd_guard.htpasswd

# ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
