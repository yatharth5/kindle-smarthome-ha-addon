#!/usr/bin/with-contenv bashio

HA_URL=$(bashio::config 'ha_url')
HA_TOKEN=$(bashio::config 'ha_token')
KINDLE_TOKEN=$(bashio::config 'kindle_token')

bashio::log.info "Writing config.json..."

cat > /app/config.json << EOF
{
    "homeassistant": {
        "wsUrl": "${HA_URL}",
        "accessToken": "${HA_TOKEN}"
    },
    "kindle-display": {
        "accessToken": "${KINDLE_TOKEN}"
    }
}
EOF

bashio::log.info "Starting Kindle SmartHome Proxy on port 4365..."
export SKIP_LIB_INSTALL=1
cd /app
exec node main.js
