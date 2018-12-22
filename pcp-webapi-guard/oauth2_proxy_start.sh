#! /bin/sh

exec /usr/local/bin/oauth2_proxy \
    --http-address=":8000" \
    --redirect-url=$OAUTH2_PROXY_REDIRECT_URL \
    --cookie-secure=false \
    --request-logging=true \
    --htpasswd-file=/usr/local/etc/pmwebd_guard.htpasswd \
    --upstream=http://localhost:44323/ \
    --provider=github \
    --github-org=$OAUTH2_PROXY_GITHUB_ORG \
    --github-team=$OAUTH2_PROXY_GITHUB_TEAM \
    --scope="read:org" \
    --email-domain='*' \


    
