FROM bcit/centos:7-supervisord

LABEL maintainer="chriswood.ca@gmail.com, Juraj Ontkanin"

ENV DOCKERIZE_ENV production

ENV CONFIGDIR /config

ENV imapproxy_version   "1.2.7"
ENV IMAPPROXYD_CONF     /etc/imapproxy.conf
ENV TLS_CA_PATH         /etc/pki/tls/certs
ENV LISTEN_PORT         143

RUN mkdir -p "$CONFIGDIR"

# Install build tools + pki
RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
    ca-certificates \
    gcc \
    make \
    openssl-devel \
    ncurses-devel \
    tcp_wrappers-devel \
    syslog-ng

# Build from source, EPEL version doesnt seem to do anything
WORKDIR /src
RUN wget https://sourceforge.net/projects/squirrelmail/files/imap_proxy/1.2.7/squirrelmail-imap_proxy-${imapproxy_version}.tar.gz \
 && tar -xvf *.tar.gz \
 && cd squirrelmail-imap_proxy* \
 && ./configure \
 && make \
 && make install \
 && make install-conf

# Clean up build
WORKDIR /tmp
RUN yum -y --setopt timeout=5 remove \
    gcc \
    make \
    openssl-devel \
    ncurses-devel \
    tcp_wrappers-devel \
 && yum clean all \
 && rm -rf /var/cache/yum/* \
 && rm -rf /src

# Fix syslog-ng errors
# this error ok: Error setting capabilities, capability management disabled; error='Operation not permitted'
RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

# Configure imapproxy for docker
RUN sed -i 's/#tls_ca_file/tls_ca_file/' /etc/imapproxy.conf \
 && sed -i 's/#tls_ca_path/tls_ca_path/' /etc/imapproxy.conf \
 && sed -i 's$/usr/share/ssl/certs/$/etc/pki/tls/certs/$' /etc/imapproxy.conf

COPY 50-copy-imapproxy-config.sh /docker-entrypoint.d/

COPY syslog-ng-extra.conf /etc/syslog-ng/conf.d/
COPY supervisor-imapproxy.conf /etc/supervisor/conf.d/

EXPOSE 143
CMD ["supervisord", "-c", "/etc/supervisor.conf"]
