#!/bin/bash
SERVICE="/lib/systemd/system/wvr-mlat2.service"

if [[ -z ${1} ]]; then
    echo --------------
    echo ERROR: requires a parameter
    exit 1
fi

cat >"$SERVICE" <<"EOF"
[Unit]
Description=wvr-mlat2
Wants=network.target
After=network.target

[Service]
User=adsbexchange
EnvironmentFile=/etc/default/wvr
ExecStart=/usr/local/share/wvr/venv/bin/mlat-client \
    --input-type $INPUT_TYPE --no-udp \
    --input-connect $INPUT \
    --server mlat.seanswildsurvival:30009 \
    --user $USER \
    --lat $LATITUDE \
    --lon $LONGITUDE \
    --alt $ALTITUDE \
    $UUID_FILE \
    $PRIVACY \
    $RESULTS
Type=simple
Restart=always
RestartSec=30
StartLimitInterval=1
StartLimitBurst=100
SyslogIdentifier=wvr-mlat2
Nice=-1

[Install]
WantedBy=default.target
EOF

if [[ -f /boot/adsb-config.txt ]]; then
    sed -i -e 's#EnvironmentFile.*#EnvironmentFile=/boot/adsbx-env\nEnvironmentFile=/boot/adsb-config.txt#' "$SERVICE"
fi

sed -i -e "s/SERVERPORT/${1}/" "$SERVICE"
if [[ -n ${2} ]]; then
    sed -i -e "s/\$RESULTS/${2}/" "$SERVICE"
fi

systemctl enable wvr-mlat2
systemctl restart wvr-mlat2
