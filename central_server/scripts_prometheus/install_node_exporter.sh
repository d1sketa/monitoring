#!/bin/bash

NODE_EXPORTER_VERSION="1.9.1"
INSTALL_DIR="/opt/node_exporter"

mkdir -p "$INSTALL_DIR"

cd /tmp
wget "https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"
tar xvfz "node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"

mv "node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter" "$INSTALL_DIR/"

rm -rf /tmp/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz /tmp/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64

if ! id "node_exporter" &>/dev/null; then
    /usr/sbin/useradd --no-create-home --shell /bin/false node_exporter
fi

chown node_exporter:node_exporter "$INSTALL_DIR/node_exporter"

cat <<EOF> /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=$INSTALL_DIR/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
systemctl status node_exporter --no-pager

"$INSTALL_DIR/node_exporter" --version
