FROM bcit/centos:7

LABEL maintainer="chriswood.ca@gmail.com"

# Install build tools + pki
RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
    ca-certificates gcc make openssl-devel ncurses-devel syslog-ng

ENV imapproxy_version   "1.2.7"
ENV IMAPPROXYD_CONF     /etc/imapproxy.conf
ENV TLS_CA_PATH         /etc/pki/tls/certs
ENV LISTEN_PORT         143

COPY 50-copy-imapproxy-config.sh docker-entrypoint.d/

# # Build from source, EPEL version doesnt seem to do anything
WORKDIR /src
RUN wget https://sourceforge.net/projects/squirrelmail/files/imap_proxy/1.2.7/squirrelmail-imap_proxy-${imapproxy_version}.tar.gz && \
    tar -xvf *.tar.gz && \
    cd squirrelmail-imap_proxy* && \
    ./configure && \
    make && \
    make install && \
    make install-conf

# Clean up build
WORKDIR /var/log
RUN yum -y --setopt timeout=5 remove \
    gcc make openssl-devel ncurses-devel && \
    yum clean all && \
    rm -rf /src

# Fix syslog-ng errors
# this error ok: Error setting capabilities, capability management disabled; error='Operation not permitted'
RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

# Configure imapproxy for docker
RUN sed -i 's/#tls_ca_file/tls_ca_file/' /etc/imapproxy.conf && \
    sed -i 's/#tls_ca_path/tls_ca_path/' /etc/imapproxy.conf && \
    sed -i 's$/usr/share/ssl/certs/$/etc/pki/tls/certs/$' /etc/imapproxy.conf && \
    mkdir /config

EXPOSE 143
cmd ["sh", "-c", "syslog-ng ; /usr/local/sbin/in.imapproxyd -f $IMAPPROXYD_CONF ; tail -F /var/log/maillog"]
