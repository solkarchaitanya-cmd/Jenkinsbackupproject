#!/bin/bash
set -euo pipefail

# Vars
JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="s3://jenkins-backup-course-end-project"

# Find latest backup from S3
LATEST_BACKUP=$(aws s3 ls $S3_BUCKET/ | sort | tail -n 1 | awk '{print $4}')

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "❌ No backups found in $S3_BUCKET"
  exit 1
fi

echo "Restoring Jenkins from backup: $LATEST_BACKUP"

# Stop Jenkins
sudo systemctl stop jenkins

# Clean old data
sudo rm -rf $JENKINS_HOME/*

# Download and extract backup
aws s3 cp $S3_BUCKET/$LATEST_BACKUP /tmp/$LATEST_BACKUP
sudo tar -xzf /tmp/$LATEST_BACKUP -C $JENKINS_HOME

# Fix permissions
sudo chown -R jenkins:jenkins $JENKINS_HOME

# Start Jenkins
sudo systemctl start jenkins

echo "✅ Jenkins restore completed from $LATEST_BACKUP"
