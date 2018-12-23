FROM centos:7

COPY oauth2_proxy /usr/local/bin
COPY oauth2_proxy_start.sh /usr/local/bin

COPY pmwebd_guard.htpasswd /usr/local/etc

ENV OAUTH2_PROXY_CLIENT_ID ""
ENV OAUTH2_PROXY_CLIENT_SECRET ""
ENV OAUTH2_PROXY_COOKIE_SECRET ""
ENV OAUTH2_PROXY_COOKIE_DOMAIN ""
ENV OAUTH2_PROXY_GITHUB_TEAM ""
ENV OAUTH2_PROXY_GITHUB_ORG ""
ENV OAUTH2_PROXY_REDIRECT_URL ""

ENTRYPOINT ["/usr/local/bin/oauth2_proxy_start.sh"]
