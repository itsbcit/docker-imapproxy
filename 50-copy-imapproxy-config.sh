TEMP_CONFFILE="$CONFIGDIR/imapproxy.conf"

if [ -f "$TEMP_CONFFILE" ]; then
    cp "$TEMP_CONFFILE" "$IMAPPROXYD_CONF"
    echo "copied custom: $TEMP_CONFFILE"
else
    echo "using default: $IMAPPROXYD_CONF"
fi

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading ${CONFIGDIR}/.DOCKERIZE.env environment"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
dockerize -template "$IMAPPROXYD_CONF":"$IMAPPROXYD_CONF"
