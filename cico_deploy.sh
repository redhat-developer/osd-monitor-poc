#!/bin/bash
yum -y install docker 
service docker start

cd grafana-hawkular
docker build -t registry.devshift.net/perf/osd-monitor:latest . 
if [ $? -eq 0 ]; then
  docker push registry.devshift.net/perf/osd-monitor:latest
  rtn=$?
fi
exit $rtn
