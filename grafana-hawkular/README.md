Based on https://github.com/hawkular/hawkular-grafana-datasource.git docker/

Installs a openshift/hawkular-oriented datasource during initialization,
which must be configured with container run-time environment variables:

* `GF_DATASOURCE_URL`
* `GF_DATASOURCE_TENANT`
* `GF_DATASOURCE_TOKEN`

The grafana admin user's password:

* `GF_SECURITY_ADMIN_PASSWORD`

