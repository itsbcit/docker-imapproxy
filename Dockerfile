FROM bcit/centos:7

LABEL maintainer="chriswood.ca@gmail.com"

# Install build tools + pki
RUN yum -y --setopt tsflags=nodocs --setopt timeout=5 install \
	ca-certificates gcc make openssl-devel ncurses-devel

ENV imapproxy_version 	"1.2.7"
ENV IMAPPROXYD_CONF 	/etc/imapproxy.conf
ENV TLS_CA_PATH 		/etc/pki/tls/certs
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

# Redirect syslog mail log to console for docker 
RUN ln -sf /dev/stdout /var/log/mail.log

EXPOSE 143

CMD /usr/local/sbin/in.imapproxyd -f $IMAPPROXYD_CONF
