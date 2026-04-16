a2enmod proxy proxy_http rewrite headers
a2dissite 000-default.conf

cat > /etc/apache2/sites-available/zabbix.local.conf <<'EOF'
<VirtualHost *:80>
    ServerName zabbix.local

    RedirectMatch ^/$ /zabbix/

    Alias /zabbix /usr/share/zabbix

    <Directory /usr/share/zabbix>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
    </Directory>
</VirtualHost>
EOF

cat > /etc/apache2/sites-available/jenkins.local.conf <<'EOF'
<VirtualHost *:80>
    ServerName jenkins.local

    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>
EOF

a2ensite zabbix.local.conf >/dev/null 2>&1
a2ensite jenkins.local.conf >/dev/null 2>&1

systemctl restart apache2

echo "apache.sh done"
