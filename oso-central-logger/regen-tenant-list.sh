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

pmmgr_dir=$PCP_ETC_DIR/pmmgr/pmmgr-tenants
mkdir -p $pmmgr_dir

prod_oso_url_suffix=8a09.starter-us-east-2.openshiftapps.com
preview_oso_url_suffix=8d00.free-int.openshiftapps.com
oso_url_suffix=$prod_oso_url_suffix
# XXX: configure


# XXX: master secret
#hmac_key=/etc/secret-volume/hmac_key
hmac_key=/dev/null


any_changed=0
replace_update_file() {
    old="$1"
    new="$2"
    
    if cmp -s "$old" "$new"; then
        rm -f "$new"
    else
        mv -f "$new" "$old"
        echo "$old changed: `cat $old`"
        any_changed=1
    fi
}


create_url()
{
    tenant="$1"
    password="$2"
    project="$3"
    metrics_prefix="$4"
    metrics_url="$5"

    namespace="$tenant$project"

    # NB: url policy right here
    # NB: metric naming policy right here
    url="https://$tenant:$password@pcp-$namespace.$oso_url_suffix$metrics_url"
    urlfile="$pmdaprometheus_dir/`echo $namespace.$metrics_prefix | tr _/- .`.url"

    echo "$url" > "$urlfile.NEW"
    replace_update_file "$urlfile" "$urlfile.NEW"
}


create_htpasswd()
{
    tenant="$1"
    password="$2"
    project="$3"

    # NB: url policy right here
    file="$htpasswd_dir/htpasswd.$tenant$project"
    htpasswd -B -b -c "$file.NEW" "$tenant" "$password"
    replace_update_file "$file" "$file.NEW"
}


create_pmmgr()
{
    tenant="$1"
    
    echo "log advisory on default {" > $pmmgr_dir/pmlogger.config.$tenant.NEW
    echo "   prometheus.$tenant" >> $pmmgr_dir/pmlogger.config.$tenant.NEW
    echo "}" >> $pmmgr_dir/pmlogger.config.$tenant.NEW
    replace_update_file $pmmgr_dir/pmlogger.config.$tenant $pmmgr_dir/pmlogger.config.$tenant.NEW
    echo "-c $pmmgr_dir/pmlogger.config.$tenant" > $pmmgr_dir/pmlogger.$tenant.NEW
    replace_update_file $pmmgr_dir/pmlogger.$tenant $pmmgr_dir/pmlogger.$tenant.NEW
}


#  XXX: should have way of sharding - selecting only a subset of tenants
tenant_list=$PCP_LOG_DIR/tenant-list

# XXX: need f8 api to populate this
# https://github.com/fabric8-services/fabric8-tenant/issues/369
if [ ! -s $tenant_list.MASTER ]; then
    exit
fi
cp $tenant_list.MASTER $tenant_list.NEW

replace_update_file $tenant_list $tenant_list.NEW
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
    create_url "$tenant" "$password" "-che" "server" "/pcp/1/metrics?target=filesys.full&target=proc.io&target=proc.psinfo&target=network.interface&target=cgroup.cpuacct&target=cgroup.memory&target=cgroup.blkio.all.throttle"
    create_url "$tenant" "$password" "-jenkins" "contentserver" "/prom9180/metrics"
    
    create_htpasswd "$tenant" "$password" "" 
    create_htpasswd "$tenant" "$password" "-che" 
    create_htpasswd "$tenant" "$password" "-jenkins"

    create_pmmgr "$tenant" "$tenant" "$tenant-che" "$tenant-jenkins"
done


# Create pmmgr configuration for all the tenants.
# We'll put each $tenant into a separate archive

cp $tenant_list $pmmgr_dir/hostid-static.NEW
replace_update_file $pmmgr_dir/hostid-static $pmmgr_dir/hostid-static.NEW
