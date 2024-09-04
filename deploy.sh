#!/bin/bash

# Define variables for paths
DEPLOY_DIR="/var/cicdappl/cicdapp"
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"

# Navigate to Jenkins workspace directory
cd "$JENKINS_WORKSPACE"

# Pull the latest changes from GitHub
git pull origin main || echo "Failed to pull latest changes from GitHub."

# Synchronize files using rsync with detailed output
rsync -av --exclude='.git' "$JENKINS_WORKSPACE/" "$DEPLOY_DIR/"

# Verify if index.js is successfully copied
if [ -f "$DEPLOY_DIR/index.js" ]; then
    echo "index.js successfully copied."
else
    echo "index.js not found in $DEPLOY_DIR. Exiting..."
    exit 1
fi

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
npm install || { echo "npm install failed"; exit 1; }

# Start the application using pm2
pm2 start ecosystem.config.js || pm2 start index.js --name "my-app"

# Verify that the application is running on port 5000
PID=$(lsof -t -i:5000)
if [ -n "$PID" ]; then
    echo "Deployment successful. Process running on port 5000 with PID $PID."
else
    echo "Deployment failed. Process not running on port 5000."
    exit 1
fi
