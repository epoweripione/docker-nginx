FROM nginx:alpine

LABEL Maintainer="Ansley Leung" \
      Description="Nginx with 404, 50x page & Log rotate everyday" \
      Reference="https://github.com/magna-z/docker-nginx-acme" \
      License="MIT License" \
      Version="1.25.2" \
      NJS_Version="0.8.0"

COPY docker-entrypoint.sh /

# Addtional files
COPY ./404.html /usr/share/nginx/html/404.html
COPY ./svg404.html /usr/share/nginx/html/svg404.html
COPY ./50x.html /usr/share/nginx/html/50x.html

COPY ./nginxBlocksIP.sh /nginxBlocksIP.sh
COPY ./nginxLogRotate.sh /nginxLogRotate.sh

# Add openssl for `docker-entrypoint.sh`
# Add GNU coreutils for date to support -d options
RUN set -ex && \
    apk add --no-cache coreutils openssl && \
    mkdir -p /etc/nginx/snippets && \
    touch /etc/nginx/snippets/BlocksIP.conf && \
    chmod +x /nginxBlocksIP.sh /nginxLogRotate.sh && \
    (crontab -l 2>/dev/null || true; echo "0 0 * * * /nginxLogRotate.sh > /dev/null") | crontab - && \
    rm -rf /tmp/* /var/cache/apk/*

    # mkdir -p /opt/acme.sh/ca/acme-v01.api.letsencrypt.org && \
    # mkdir -p /opt/acme.sh/ca/acme-v02.api.letsencrypt.org && \

ENTRYPOINT ["/docker-entrypoint.sh"]
