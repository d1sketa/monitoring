#!/bin/bash

PROMETHEUS_VERSION="2.51.1"
PROMETHEUS_INSTALL_ROOT="/opt/prometheus"
PROMETHEUS_FOLDER_TSDATA="${PROMETHEUS_INSTALL_ROOT}/data"

mkdir -p "$PROMETHEUS_INSTALL_ROOT"
mkdir -p "$PROMETHEUS_FOLDER_TSDATA"


cd /tmp || exit

wget "https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"
tar xvfz "prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

mv "prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus" "$PROMETHEUS_INSTALL_ROOT/"
mv "prometheus-$PROMETHEUS_VERSION.linux-amd64/consoles" "$PROMETHEUS_INSTALL_ROOT/"
mv "prometheus-$PROMETHEUS_VERSION.linux-amd64/console_libraries" "$PROMETHEUS_INSTALL_ROOT/"

rm -rf "prometheus-$PROMETHEUS_VERSION.linux-amd64"
rm -f "prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"


cat <<EOF> "$PROMETHEUS_INSTALL_ROOT/prometheus.yml"
global:
  scrape_interval: 15s

scrape_configs:
  - job_name      : "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF

id -u prometheus &>/dev/null || useradd -rs /bin/false prometheus

chown -R prometheus:prometheus "$PROMETHEUS_INSTALL_ROOT"
chmod +x "$PROMETHEUS_INSTALL_ROOT/prometheus"

cat <<EOF> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
ExecStart=${PROMETHEUS_INSTALL_ROOT}/prometheus \
  --config.file      ${PROMETHEUS_INSTALL_ROOT}/prometheus.yml \
  --storage.tsdb.path ${PROMETHEUS_FOLDER_TSDATA} \
  --web.console.templates=${PROMETHEUS_INSTALL_ROOT}/consoles \
  --web.console.libraries=${PROMETHEUS_INSTALL_ROOT}/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus --no-pager

"${PROMETHEUS_INSTALL_ROOT}/prometheus" --version
