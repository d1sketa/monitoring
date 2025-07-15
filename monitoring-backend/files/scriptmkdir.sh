#!/bin/bash

# Создаем корневую директорию
mkdir -p monitoring-backend

cd monitoring-backend || exit 1

# Создаем главный docker-compose файл
touch docker-compose.global.yml

# Создаем каталоги и пустые файлы внутри
mkdir -p prometheus
touch prometheus/prometheus.yml prometheus/alert.rules.yml

mkdir -p alertmanager
touch alertmanager/config.yml

mkdir -p blackbox-exporter
touch blackbox-exporter/config.yml

mkdir -p postgres
touch postgres/init.sql

mkdir -p nginx/certs
touch nginx/nginx.conf nginx/certs/nginx.crt nginx/certs/nginx.key

mkdir -p grafana/provisioning/datasources
touch grafana/provisioning/datasources/datasource.yml

mkdir -p grafana/provisioning/dashboards

mkdir -p grafana/dashboards

mkdir -p custom_exporter_bash
touch custom_exporter_bash/Dockerfile custom_exporter_bash/start.sh

echo "Структура каталогов и файлов monitoring-backend создана."
