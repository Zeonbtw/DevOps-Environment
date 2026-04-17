#!/usr/bin/env bash
set -euo pipefail

# if container exists just start
if docker inspect jenkins >/dev/null 2>&1; then
  docker start jenkins >/dev/null 2>&1 || true
else
  # if not, create with volume
  docker run -d \
    --name jenkins \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    jenkins/jenkins:lts-jdk21 >/dev/null
fi

echo "Waiting for Jenkins to start..."

# Wait until password file appears
until docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword; do
  sleep 2
done

echo "Jenkins is ready"

echo "Admin password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "jenkins.sh done"
