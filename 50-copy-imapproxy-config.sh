TEMP_CONFFILE=/config/imapproxy.conf
[ -f "$TEMP_CONFFILE" ] && { cp $TEMP_CONFFILE $IMAPPROXYD_CONF; echo "copied custom: $TEMP_CONFFILE"; } \
	|| echo "using default: $IMAPPROXYD_CONF"
