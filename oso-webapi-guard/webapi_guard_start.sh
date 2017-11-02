#! /bin/sh

# start two processes: a background shell script fragment that
# periodically fetches a given URL for authentication data

REFRESH0=30
REFRESH=3600 # re-fetch

URL=${OSIO_ACL_SERVER}/tenant-auth/htpasswd.${OSIO_NAMESPACE}  # as per oso-central-webapi-guard & oso-central-logger
HTPASSWD=/etc/httpd/conf/pmwebd_guard.htpasswd

echo "Fetching $URL to $HTPASSWD"
if [ -n "$URL" ]; then
   curl "$URL" -o /tmp/file.$$ && mv /tmp/file.$$ "$HTPASSWD"
   (while true; do
        curl "$URL" -o /tmp/file.$$ && mv /tmp/file.$$ "$HTPASSWD"
        if [ -f "$HTPASSWD" ]; then
            sleep $REFRESH
        else
            sleep $REFRESH0 # no file yet, sleep less
        fi
    done) &
   p1=$!
fi

/usr/sbin/httpd -D FOREGROUND &
p2=$!

trap "kill $p1 $p2; exit" 0 1 2 3 4 5 9 15 28 # SIGWINCH
wait
