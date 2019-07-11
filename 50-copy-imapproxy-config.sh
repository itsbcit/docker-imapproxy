TEMP_CONFFILE="$CONFIGDIR/imapproxy.conf"

if [ -f "${TEMP_CONFFILE}.tmpl" ]; then
    cp "${TEMP_CONFFILE}.tmpl" "${IMAPPROXYD_CONF}.tmpl"
    echo "copied custom: ${TEMP_CONFFILE}.tmpl"
elif [ -f "$TEMP_CONFFILE" ]; then
    cp "$TEMP_CONFFILE" "$IMAPPROXYD_CONF"
    echo "copied custom: $TEMP_CONFFILE"
else
    echo "using default: $IMAPPROXYD_CONF"
fi

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading: ${CONFIGDIR}/.DOCKERIZE.env"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
if [ -f "${IMAPPROXYD_CONF}.tmpl" ]; then
    echo "dockerizing: ${IMAPPROXYD_CONF}.tmpl"
    echo "         =>  ${IMAPPROXYD_CONF}"
    dockerize -template "${IMAPPROXYD_CONF}.tmpl":"$IMAPPROXYD_CONF" \
    && rm -f "${IMAPPROXYD_CONF}.tmpl"
done
