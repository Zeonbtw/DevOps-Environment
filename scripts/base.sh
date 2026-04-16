#!/usr/bin/env bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y wget gpg lsb-release curl ca-certificates

# HashiCorp Vault
rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --batch --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Zabbix
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
dpkg -i zabbix-release_latest_7.0+debian12_all.deb

# Install all packages
apt-get update

apt-get install -y vault

apt-get install -y docker.io
systemctl enable docker
systemctl restart docker

apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

echo "base.sh done"
