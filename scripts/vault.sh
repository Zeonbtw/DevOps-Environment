#!/usr/bin/env bash
set -euo pipefail

# Create systemd service
cat > /etc/systemd/system/vault.service <<EOF
[Unit]
Description=Vault Dev Server
After=network.target

[Service]
ExecStart=/usr/bin/vault server -dev -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start on boot
systemctl daemon-reload
systemctl enable vault
systemctl start vault
sleep 3

# Verify Vault is running
curl http://127.0.0.1:8200/v1/sys/health
