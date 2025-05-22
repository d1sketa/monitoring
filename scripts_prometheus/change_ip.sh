#!/bin/bash

# Проверка прав суперпользователя
if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите скрипт с sudo"
  exit 1
fi

# Создаем резервную копию конфига
cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak

# Перезаписываем конфиг (замените значения на свои)
cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.1.100/24]  # - Здесь ставим свои значения. Новый IP и маска
      gateway4: 192.168.1.1          # - Здесь ставим сови значения. Шлюз
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4] # Здесь ставим свои значения. DNS
EOF

# Применяем изменения
netplan apply

# Проверяем результат
ip a show eth0
