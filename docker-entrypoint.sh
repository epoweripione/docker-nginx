#!/bin/sh

set -e

crond -b -L /var/log/crond.log


# forbidden ip access for https: gen self-signed server certificate
GEN_DENY_IP_ACCESS_SSL="yes"
if [ -s "/etc/nginx/ssl/deny_ip_access/self-signed.crt" ]; then
    EXPIRE_DATE=$(openssl x509 -in /etc/nginx/ssl/deny_ip_access/self-signed.crt -noout -enddate \
                | cut -d= -f2- \
                | xargs -I{} date -d {})
    START_SECOND=$(date +%s)
    END_SECOND=$(date -d "$EXPIRE_DATE" +%s)
    DIFF_SECOND=$(( END_SECOND - START_SECOND ))
    # regen certificate when expire in 30 days
    EXPIRE_SECOND=$(( 30 * 24 * 60 * 60 ))
    if [ $DIFF_SECOND -gt $EXPIRE_SECOND ]; then
        GEN_DENY_IP_ACCESS_SSL="no"
    fi
fi

if [ "$GEN_DENY_IP_ACCESS_SSL" == "yes" ]; then
    SSLDIR="/etc/nginx/ssl/deny_ip_access" && \
        SSLFILE="self-signed" && \
        SSLDAYS="3650" && \
        SSLPASS="PassW0rd" && \
        DOMAIN="localhost" && \
        SUBJECT="/C=US/ST=Mars/L=iTranswarp/O=iTranswarp/OU=iTranswarp/CN=$DOMAIN" && \
        : && \
        mkdir -p "$SSLDIR" && cd "$SSLDIR" && rm -f "$SSLDIR/$SSLFILE.*" && \
        : && \
        openssl genrsa -des3 -passout pass:$SSLPASS -out $SSLFILE.pass.key 2048 && \
        openssl rsa -passin pass:$SSLPASS -in $SSLFILE.pass.key -out $SSLFILE.key && \
        openssl req -new -subj $SUBJECT -key $SSLFILE.key -out $SSLFILE.csr && \
        openssl x509 -req -days $SSLDAYS -in $SSLFILE.csr -signkey $SSLFILE.key -out $SSLFILE.crt && \
        : && \
        cd -
fi


nginx -g "daemon off;"
