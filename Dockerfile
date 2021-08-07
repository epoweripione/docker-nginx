FROM nginx:alpine

LABEL Maintainer="Ansley Leung" \
      Description="Nginx with embedded Let's Encrypt client ACME.sh" \
      Reference="https://github.com/magna-z/docker-nginx-acme" \
      License="MIT License" \
      Version="1.21.1"

# ENV TZ=Asia/Shanghai
# RUN set -ex && \
#     apk add --no-cache tzdata && \
#     ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
#     echo $TZ > /etc/timezone

# ACME: https://github.com/Neilpang/acme.sh
COPY docker-entrypoint.sh /

# RUN set -ex && \
#     apk add --no-cache ca-certificates curl git openssl socat && \
#     git clone --depth=1 https://github.com/acmesh-official/acme.sh.git /tmp/acme.sh && \
#     cd /tmp/acme.sh && \
#     ./acme.sh --install --home /opt/acme.sh --config-home /etc/nginx/ssl && \
#     cd ~ && \
#     crontab -l | sed "s|acme.sh --cron|acme.sh --cron --renew-hook \"nginx -s reload\"|g" | crontab - && \
#     ln -s /opt/acme.sh/acme.sh /usr/bin/acme.sh && \
#     chmod +x /docker-entrypoint.sh && \
#     rm -rf /tmp/* /var/cache/apk/*


# Addtional files
COPY ./404.html /usr/share/nginx/html/404.html
COPY ./svg404.html /usr/share/nginx/html/svg404.html
COPY ./50x.html /usr/share/nginx/html/50x.html

COPY ./nginxBlocksIP.sh /nginxBlocksIP.sh
COPY ./nginxLogRotate.sh /nginxLogRotate.sh


# Add GNU coreutils for date to support -d options
RUN set -ex && \
    apk add --no-cache coreutils && \
    mkdir -p /etc/nginx/snippets && \
    touch /etc/nginx/snippets/BlocksIP.conf && \
    chmod +x /nginxBlocksIP.sh /nginxLogRotate.sh && \
    (crontab -l 2>/dev/null || true; echo "0 0 * * * /nginxLogRotate.sh > /dev/null") | crontab - && \
    rm -rf /tmp/* /var/cache/apk/*

    # mkdir -p /opt/acme.sh/ca/acme-v01.api.letsencrypt.org && \
    # mkdir -p /opt/acme.sh/ca/acme-v02.api.letsencrypt.org && \

ENTRYPOINT ["/docker-entrypoint.sh"]
