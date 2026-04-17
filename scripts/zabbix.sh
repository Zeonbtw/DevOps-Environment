#!/usr/bin/env bash
set -euo pipefail

DB_NAME="zabbix"
DB_USER="zabbix"
DB_PASS="password"

systemctl enable mariadb
systemctl restart mariadb

mysql -uroot <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EOF

if ! mysql -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "SELECT 1 FROM users LIMIT 1;" >/dev/null 2>&1; then
  zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
    mysql --default-character-set=utf8mb4 -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}"
fi

mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;"
systemctl restart mariadb

sed -i "s/^#\?DBPassword=.*/DBPassword=${DB_PASS}/" /etc/zabbix/zabbix_server.conf
grep -q '^DBPassword=' /etc/zabbix/zabbix_server.conf || \
echo "DBPassword=${DB_PASS}" | sudo tee -a /etc/zabbix/zabbix_server.conf

grep -q "UserParameter=service.status" /etc/zabbix/zabbix_agentd.conf || \
echo 'UserParameter=service.status[*],systemctl is-active $1 | grep -c "^active"' >> /etc/zabbix/zabbix_agentd.conf

grep -q "UserParameter=jenkins.status" /etc/zabbix/zabbix_agentd.conf || \
echo 'UserParameter=jenkins.status,curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/login | grep -c 200' >> /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-server zabbix-agent apache2
systemctl restart zabbix-server zabbix-agent apache2

echo "zabbix.sh done"
