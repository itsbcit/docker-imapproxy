TEMP_CONFFILE="/config/imapproxy.conf"
[ -f "$TEMP_CONFFILE" ] && { cp "$TEMP_CONFFILE" "$IMAPPROXYD_CONF"; echo "copied custom: $TEMP_CONFFILE"; } \
	|| echo "using default: $IMAPPROXYD_CONF"

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading ${CONFIGDIR}/.DOCKERIZE.env environment"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
dockerize -template "$IMAPPROXYD_CONF":"$IMAPPROXYD_CONF"
