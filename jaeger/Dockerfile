FROM centos:7

RUN mkdir -p /opt; cd /opt; curl -L https://github.com/jaegertracing/jaeger/releases/download/v1.8.2/jaeger-1.8.2-linux-amd64.tar.gz | tar xvfz -

# incoming trace data ports
EXPOSE 5775/udp
EXPOSE 6831/udp
EXPOSE 6832/udp
# jaeger-agent
EXPOSE 5778
# zipkin collector
EXPOSE 9411
# jaeger-collector, tchannel
EXPOSE 14267
# jaeger-collector, http
EXPOSE 14268
# health: 14269: not needed
# ui, query, metrics, http
EXPOSE 16686

ENTRYPOINT ["/opt/jaeger-1.8.2-linux-amd64/jaeger-all-in-one", "--query.base-path", "/jaeger", "--metrics-backend", "prometheus", "--collector.zipkin.http-port", "9411"]
