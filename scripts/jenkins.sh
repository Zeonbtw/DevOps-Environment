#!/usr/bin/env bash
set -euo pipefail

# Remove old container if exists
docker rm -f jenkins 2>/dev/null || true
docker volume rm jenkins_home 2>/dev/null || true

# Create volume if not exists
docker volume create jenkins_home >/dev/null 2>&1 || true

# Run Jenkins
docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts-jdk21

echo "Waiting for Jenkins to start..."

# Wait until password file appears
until docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword; do
  sleep 2
done

echo "Jenkins is ready"

echo "Admin password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "jenkins.sh done"
