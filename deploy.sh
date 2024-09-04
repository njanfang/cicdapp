#!/bin/bash

# Define variables for paths
DEPLOY_DIR="/var/project/cicddeploy"
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"

# Navigate to Jenkins workspace directory
cd "$JENKINS_WORKSPACE"

# Synchronize files using rsync
rsync -av --exclude='.git' "$JENKINS_WORKSPACE/" "$DEPLOY_DIR/"

# Navigate to the deploy directory
cd "$DEPLOY_DIR"

# Stop the pm2 process (if running)
pm2 stop all || echo "No pm2 process running"

# Find the process ID (PID) using port 5000 and kill it
PID=$(lsof -t -i:5000)
if [ -n "$PID" ]; then
  su -c "kill -9 $PID" -s /bin/bash root
fi

# Install Node.js dependencies
npm install

# Start the application using pm2
pm2 start ecosystem.config.js || pm2 start index.js --name "my-app"

# Verify that the application is running on port 5000
PID=$(lsof -t -i:5000)
if [ -n "$PID" ]; then
  echo "Deployment successful. Process running on port 5000 with PID $PID."
else
  echo "Deployment failed. Process not running on port 5000."
fi
