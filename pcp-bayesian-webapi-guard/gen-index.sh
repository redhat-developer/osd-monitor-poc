#! /bin/sh

http_prefix=${HTTP_PREFIX}


component_num_columns=9
component_column_name() {
    case $1 in
        1) echo -n 'fs fullness' ;;
        2) echo -n 'process i/o' ;;
        3) echo -n 'network i/o' ;;
        4) echo -n 'fds, threads' ;;
        5) echo -n 'rss, vsz' ;;
        6) echo -n 'utime, stime' ;;
        7) echo -n 'go gc' ;;
        8) echo -n 'go http traffic' ;;
        9) echo -n 'go http latency' ;;
        *) exit 1 ;;
    esac
}

component_column_metrics() {
    case $1 in
        1) echo -n $2'filesys.full.*' ;;
        2) echo -n $2'proc.io.*_bytes.*' ;;
        3) echo -n $2'network.interface.in.bytes.*'$3$2'network.interface.out.bytes.*' ;;
        4) echo -n $2'proc.fd.count.*'$3$2'proc.psinfo.threads.*' ;;
        5) echo -n $2'proc.psinfo.rss.*'$3$2'proc.psinfo.vsize.*'$3$2'cgroup.memory.usage.*' ;;
        6) echo -n $2'proc.psinfo.?time.*' ;;
        7) echo -n $2'prometheus.wit.go_gc_duration_seconds_sum' ;;
        8) echo -n $2'prometheus.wit.http_*_size_bytes_sum.*' ;;
        9) echo -n $2'prometheus.wit.http_request_duration_microseconds_sum.*' ;;
        *) exit 1 ;;
    esac
}


# generate the repeating portions of the index page
set -e
exec > index.html
cat index.html.tmpl | sed -n -e '/CUT HERE TOP/,/CUT HERE COMPONENT/ {p} '

echo '<table><tr>
<th>pod</th>'
for colno in `seq $component_num_columns`; do
    echo '<th>'
    component_column_name $colno
    echo '</th>'
done
echo '</tr>'

for component in \
                 bayesian-anitya \
                 bayesian-anitya-update-job \
                 bayesian-api \
                 bayesian-data-importer \
                 bayesian-gremlin-http \
                 bayesian-jobs \
                 bayesian-kronos-maven \
                 bayesian-kronos-pypi \
                 bayesian-pgbouncer \
                 bayesian-worker-api \
                 bayesian-worker-api-graph-import \
                 bayesian-worker-ingestion \
                 bayesian-worker-ingestion-graph-import \
                 bayesian-worker-priority \
                 bayesian-worker-priority-graph-import \
                 devshift-monitor-file \
                 f8a-firehose-fetcher \
                 f8a-license-analysis \
                 f8a-worker-scaler \
                 fabric8-analytics-stack-report-ui \
		 osd-monitor
do
    echo '<tr>'
    
    # grafana dashboard in first column
    echo -n '<td><a href="'$http_prefix'/grafana/index.html#/dashboard/script/multichart.js?from=now-6h&to=now&span12s=12&height=150'
    for colno in `seq $component_num_columns`; do
        echo -n '&target='
        component_column_metrics $colno $component'-*.' ','
    done
    echo '">'$component'</a></td>'

    # individual sparklines for same columns
    for colno in `seq $component_num_columns`; do
        echo '<td>'
        echo -n '<img class="pcp" src="'$http_prefix'/graphite/render/?from=-6h&until=now&maxDataPoints=36&width=80&height=30&graphOnly=true&lineWidth=0.7&target='
        component_column_metrics $colno $component'-*.' '&target=' 
        echo '"></td>'
    done
    
    echo '</tr>'
done

# another row for "ALL" apps
component=ALL
echo '<tr></tr>'
echo '<tr>'

# blank cell
echo '<td></td>'

# individual sparklines for same columns
for colno in `seq $component_num_columns`; do
    echo -n '<td><a href="'$http_prefix'/grafana/index.html#/dashboard/script/multichart.js?from=now-6h&to=now&template=*&span12s=12&height=450&target='
    component_column_metrics $colno '' ',' 
    echo '">ALL</a></td>'
done

echo '</tr>'
echo '</table>'

cat index.html.tmpl | sed -n -e '/CUT HERE COMPONENT/,/CUT HERE BOTTOM/ {p} '
