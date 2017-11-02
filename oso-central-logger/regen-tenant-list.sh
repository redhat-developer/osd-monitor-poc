#! /bin/sh

# Scan the list of OSO tenants.

# For each perhaps-live tenant, ensure that there is a set of
# pmdaprometheus .url files for that tenant, listing all of their
# prometheus/pcp exporter endpoints.  Each URL is authenticated with
# https://user:password@..../ "plain", and these urls containing
# _plaintext_ passwords go into the .url files.
#
# Each tenant-side OSO prometheus-relayer container will periodically
# fetch a htpasswd ciphertext form of the passwords from a nearby
# public-facing web server from a local directory.  (We can't
# configure the OSO tenants ahead of time.)
#
# This script chooses a unique password for each tenant.  It's unique
# because we don't want a tenant to be able to use his assigned
# password to spy on anyone else's prometheus server.  (The tenant's
# container will have access to his own plaintext, as it's coming down
# the http route.)
#
# This could be a brand new random password every time.


pmdaprometheus_dir=$PCP_PMDAS_DIR/prometheus/urls.d
mkdir -p $pmdaprometheus_dir

htpasswd_dir=$PCP_LOG_DIR/tenant-auth
mkdir -p $htpasswd_dir
touch $htpasswd_dir/index.html  # don't let pmweb auto-generate a listings

tenant_list=$PCP_LOG_DIR/tenant-list
# XXX: need f8 api to populate this
# https://github.com/fabric8-services/fabric8-auth/issues/150


prod_oso_url_suffix=8a09.starter-us-east-2.openshiftapps.com
preview_oso_url_suffix=8d00.free-int.openshiftapps.com
oso_url_suffix=$prod_oso_url_suffix

#hmac_key=/etc/secret-volume/hmac_key
hmac_key=/dev/null


if [ ! -s $tenant_list ]; then
    exit
fi


create_url()
{
    tenant="$1"
    password="$2"
    project="$3"
    metrics_url="$4"

    namespace="$tenant$project"

    # NB: url policy right here
    # NB: metric naming policy right here
    url="https://$tenant:$password@$namespace.$oso_url_suffix$metrics_url"
    urlfile="$pmdaprometheus_dir/`echo $namespace.$metrics_url | sed -e s,/osio_metrics/,, | tr _/- .`.url"

    echo "$url" > "$urlfile"
    echo "$urlfile" "$url"
}


create_htpasswd()
{
    tenant="$1"
    password="$2"
    project="$3"

    # NB: url policy right here
    file="$htpasswd_dir/htpasswd.$tenant$project"
    htpasswd -B -b -c $file "$tenant" "$password"
    echo "$file" `cat $file`
}


for tenant in `cat $tenant_list`; do
    if expr "$tenant" : "^[a-zA-Z0-9_-]*$" >/dev/null; then
        echo processing tenant $tenant
        # ok
    else
        echo "ignored tenant $tenant"
        continue
    fi
        
    tenant_htpasswd=$htpasswd_dir/$tenant.htpasswd
    if [ -s $tenant_htpasswd ]; then
        # tenant data already initialized; .urls'
        continue
    fi

    password=`echo $tenant | sha256hmac -k $hmac_key - | awk '{print $1}'`
    
    tenant_urlbase=$pmdaprometheus_dir/$tenant
    
    # XXX: osio architecture: the set of exported urls for each namespace of a tenant
    create_url "$tenant" "$password" "" "/osio_metrics/prom"
    create_url "$tenant" "$password" "-run" "/osio_metrics/prom"
    create_url "$tenant" "$password" "-stage" "/osio_metrics/prom"
    create_url "$tenant" "$password" "" "/osio_metrics/pcp"
    create_url "$tenant" "$password" "-run" "/osio_metrics/pcp"
    create_url "$tenant" "$password" "-stage" "/osio_metrics/pcp"
    create_url "$tenant" "$password" "-che" "/osio_metrics/pcp"
    create_url "$tenant" "$password" "-jenkins" "/osio_metrics/jenkins"
    create_url "$tenant" "$password" "-jenkins" "/osio_metrics/content_repo"
    
    create_htpasswd "$tenant" "$password" "" 
    create_htpasswd "$tenant" "$password" "-run" 
    create_htpasswd "$tenant" "$password" "-stage" 
    create_htpasswd "$tenant" "$password" "-che" 
    create_htpasswd "$tenant" "$password" "-jenkins" 
done
