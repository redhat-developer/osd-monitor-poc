#!/bin/bash
yum -y install docker 
service docker start

cd pcp-node-collector
docker build -t registry.devshift.net/perf/pcp-node-collector:latest . 
if [ $? -eq 0 ]; then
  docker push registry.devshift.net/perf/pcp-node-collector:latest
  rtn=$?
fi
exit $rtn
