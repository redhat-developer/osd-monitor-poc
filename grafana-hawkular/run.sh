#! /bin/bash -e

: "${GF_PATHS_DATA:=/var/lib/grafana}"
: "${GF_PATHS_LOGS:=/var/log/grafana}"
: "${GF_PATHS_PLUGINS:=/var/lib/grafana/plugins}"
: "${GF_SERVER_HTTP_PORT:=3000}"
: "${GF_SECURITY_ADMIN_USER:=admin}"
# The ones below need to be filled in at docker-run / oc-run time
: "${GF_SECURITY_ADMIN_PASSWORD:=admin}"
: "${GF_DATASOURCE_URL:=fillmein}"
: "${GF_DATASOURCE_TENANT:=fillmein}"
: "${GF_DATASOURCE_TOKEN:=fillmein}"
: "${GF_DATASOURCE_TOKENPATH:=fillmein}"
: "${PCP_DATASOURCE_URL:=fillmein}"

# Launch pmcd side process
./run-pmcd.sh &

/usr/sbin/grafana-server               \
  --homepath=/usr/share/grafana         \
  --config=/etc/grafana/grafana.ini      \
  cfg:default.paths.data="$GF_PATHS_DATA" \
  cfg:default.paths.logs="$GF_PATHS_LOGS"  \
  cfg:default.paths.plugins="$GF_PATHS_PLUGINS" &

server=http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@localhost:${GF_SERVER_HTTP_PORT}


# register the hawkular datasource
# there is no non-GUI way of doing this, as of grafana 4.1
# https://github.com/grafana/grafana/issues/1789

# Wait until the server process is up and running
until /usr/bin/curl -s $server/ -o /dev/null
do
    echo waiting for grafana...
    sleep 1
done   

echo registering hawkular datasource

if [ -f ${GF_DATASOURCE_TOKENPATH} ]; then
    GF_DATASOURCE_TOKEN=`cat ${GF_DATASOURCE_TOKENPATH}`
fi    

/usr/bin/curl $server/api/datasources -s -X POST -H 'Content-Type: application/json;charset=utf-8' -d '{"name":"hawkular","type":"hawkular-datasource","url":"'${GF_DATASOURCE_URL}'","access":"proxy","jsonData":{"tenant":"'${GF_DATASOURCE_TENANT}'","token":"'${GF_DATASOURCE_TOKEN}'"},"secureJsonFields":{},"withCredentials":true,"isDefault":true}'

echo registering pcp datasource

/usr/bin/curl $server/api/datasources -s -X POST -H 'Content-Type: application/json;charset=utf-8' -d '{"name":"pcp","type":"graphite","url":"'${PCP_DATASOURCE_URL}'","access":"proxy"}'

wait
