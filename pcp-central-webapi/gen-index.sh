#! /bin/sh

http_prefix=${HTTP_PREFIX}

node_num_columns=8
node_column_name() {
    case $1 in    
        1) echo -n 'load avg' ;;
        2) echo -n 'processes' ;;
        3) echo -n 'idle cpu%' ;;
        4) echo -n 'user cpu%' ;;
        5) echo -n 'sys cpu%' ;;
        6) echo -n 'disk i/o' ;;
        7) echo -n 'memory avail' ;;
        8) echo -n 'memory fault' ;;
        *) exit 1 ;;
    esac
}

node_column_metrics() {
    case $1 in
        1) echo -n 'kernel.all.load.1%20minute' ;;
        2) echo -n 'kernel.all.running'$3'kernel.all.blocked' ;;
        3) echo -n 'kernel.cpu.util.idle' ;;
        4) echo -n 'kernel.cpu.util.user' ;;
        5) echo -n 'kernel.cpu.util.sys' ;;
        6) echo -n 'disk.dev.read_bytes.*'$3'disk.dev.write_bytes.*' ;;
        7) echo -n 'mem.util.available'$3'mem.util.used' ;;
        8) echo -n 'mem.vmstat.*fault' ;;
        *) exit 1 ;;
    esac
}



db_num_columns=7
db_column_name() {
    case $1 in    
        1) echo -n 'blocks read' ;;
        2) echo -n 'blocks hit' ;;
        3) echo -n 'tups deleted' ;;
        4) echo -n 'tups fetched' ;;
        5) echo -n 'tups inserted' ;;
        6) echo -n 'tups updated' ;;
        7) echo -n 'tups returned' ;;
        *) exit 1 ;;
    esac
}

db_column_metrics() {
    case $1 in
        1) echo -n $2'postgresql.statio.*.*_blks_read.*' ;;
        2) echo -n $2'postgresql.statio.*.*_blks_hit.*' ;;
        3) echo -n $2'postgresql.stat.database.tup_deleted.*' ;;
        4) echo -n $2'postgresql.stat.database.tup_fetched.*' ;;
        5) echo -n $2'postgresql.stat.database.tup_inserted.*' ;;
        6) echo -n $2'postgresql.stat.database.tup_updated.*' ;;
        7) echo -n $2'postgresql.stat.database.tup_returned.*' ;;        
        *) exit 1 ;;
    esac
}


component_num_columns=7
component_column_name() {
    case $1 in
        1) echo -n 'fs fullness' ;;
        2) echo -n 'network i/o' ;;
        3) echo -n 'fds, threads' ;;
        4) echo -n 'rss, vsz' ;;
        5) echo -n 'go gc' ;;
        6) echo -n 'go http traffic' ;;
        7) echo -n 'go http latency' ;;
        *) exit 1 ;;
    esac
}

component_column_metrics() {
    case $1 in
        1) echo -n $2'filesys.full.*' ;;
        2) echo -n $2'network.interface.in.bytes.*'$3$2'network.interface.out.bytes.*' ;;
        3) echo -n $2'proc.fd.count.*'$3$2'proc.psinfo.threads.*' ;;
        4) echo -n $2'proc.psinfo.rss.*'$3$2'proc.psinfo.vsize.*'$3$2'cgroup.memory.usage.*' ;;
        5) echo -n $2'prometheus.*.go_gc_duration_seconds_sum' ;;
        6) echo -n $2'prometheus.*.http_*_size_bytes_sum.*'$3$2'prometheus.*.traefik_requests_total.*' ;;
        7) echo -n $2'prometheus.*.http_request_duration_microseconds_sum.*'$3$2'prometheus.*.traefik_request_duration_seconds_sum.*' ;;
        *) exit 1 ;;
    esac
}


# generate the repeating portions of the index page
set -e
exec > index.html
cat index.html.tmpl | sed -n -e '/CUT HERE TOP/,/CUT HERE NODE/ {p} '

echo '<table><tr>
<th>node</th>'
for colno in `seq $node_num_columns`; do
    echo '<th>'
    node_column_name $colno
    echo '</th>'
done
echo '</tr>'

component=NODE
echo '<tr>'
# grafana dashboard in first column
echo -n '<td><a href="'$http_prefix'/grafana/index.html#/dashboard/script/multichart.js?from=now-6h&to=now&template='$component'*&span12s=12&height=150'
for colno in `seq $node_num_columns`; do
    echo -n '&target='
    node_column_metrics $colno $component ','
done
echo '">'$component'</a></td>'

# individual sparklines for same columns
for colno in `seq $node_num_columns`; do
    echo '<td>'
    echo -n '<img class="pcp" src="'$http_prefix'/graphite/render/?from=-6h&until=now&maxDataPoints=36&width=100&height=40&graphOnly=true&lineWidth=0.7&target='$component'-*.'
    node_column_metrics $colno $component '&target='$component'-*.' 
    echo '"></td>'
done

echo '</tr>'
echo '</table>'

cat index.html.tmpl | sed -n -e '/CUT HERE NODE/,/CUT HERE DBS/ {p} '

echo '<table><tr>
<th>database</th>'
for colno in `seq $db_num_columns`; do
    echo '<th>'
    db_column_name $colno
    echo '</th>'
done
echo '</tr>'

component=DB
for db in DB-auth DB-f8cluster DB-f8core DB-f8tenant DB-jenkins-proxy
do
    echo '<tr>'
    
    # grafana dashboard in first column
    echo -n '<td><a href="'$http_prefix'/grafana/index.html#/dashboard/script/multichart.js?from=now-6h&to=now&span12s=12&height=150'
    for colno in `seq $db_num_columns`; do
        echo -n '&target='
        db_column_metrics $colno $db'.' ','
    done
    echo '">'$db'</a></td>'

    # individual sparklines for same columns
    for colno in `seq $db_num_columns`; do
        echo '<td>'
        echo -n '<img class="pcp" src="'$http_prefix'/graphite/render/?from=-6h&until=now&maxDataPoints=36&width=100&height=40&graphOnly=true&lineWidth=0.7&target='
        db_column_metrics $colno $db'.' '&target=' 
        echo '"></td>'
    done
    echo '</tr>'
done

# another row for "ALL" databases
component=ALL
echo '<tr></tr>'
echo '<tr>'

# blank cell
echo '<td></td>'

# individual sparklines for same columns
for colno in `seq $db_num_columns`; do
    echo -n '<td><a href="'$http_prefix'/grafana/index.html#/dashboard/script/multichart.js?from=now-6h&to=now&template=*&span12s=12&height=450&target='
    db_column_metrics $colno '' ',' 
    echo '">ALL</a></td>'
done

echo '</tr>'
echo '</table>'

cat index.html.tmpl | sed -n -e '/CUT HERE DBS/,/CUT HERE COMPONENT/ {p} '

echo '<table><tr>
<th>pod</th>'
for colno in `seq $component_num_columns`; do
    echo '<th>'
    component_column_name $colno
    echo '</th>'
done
echo '</tr>'

for component in auth build-tool-detector rhche core f8build f8env f8notification f8osoproxy f8tenant f8toggles jenkins-idler jenkins-proxy f8cluster osd-monitor keycloak-server test-keeper work-in-progress hook
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
        echo -n '<img class="pcp" src="'$http_prefix'/graphite/render/?from=-6h&until=now&maxDataPoints=36&width=100&height=40&graphOnly=true&lineWidth=0.7&target='
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
