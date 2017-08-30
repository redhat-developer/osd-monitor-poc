#! /bin/sh

# start two processes: a background shell script fragment that
# periodically fetches a given URL for authentication data

REFRESH=14400
URL=${HTPASSWD_URL}
HTPASSWD=/etc/httpd/conf/pmwebd_guard.htpasswd

if [ -n "$URL" ]; then
   curl "$URL" -o /tmp/file.$$ && mv /tmp/file.$$ "$HTPASSWD" || exit 1
   (while true; do
        sleep $REFRESH
        curl "$URL" -o /tmp/file.$$ && mv /tmp/file.$$ "$HTPASSWD"
    done) &
   p1=$!
fi

/usr/sbin/httpd -D FOREGROUND &
p2=$!

trap "kill $p1 $p2; exit" 0 1 2 3 4 5 9 15 28 # SIGWINCH
wait
