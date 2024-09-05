#!/bin/bash

# Define paths
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"
DEPLOY_DIR="/var/cicdappl/cicdapp"

# Navigate to Jenkins workspace
echo "Navigating to Jenkins workspace: $JENKINS_WORKSPACE"
cd "$JENKINS_WORKSPACE" || { echo "Failed to navigate to Jenkins workspace"; exit 1; }

# Copy files to deployment directory
echo "Copying files from Jenkins workspace to $DEPLOY_DIR"
cp -r * "$DEPLOY_DIR" || { echo "Failed to copy files to $DEPLOY_DIR"; exit 1; }

# Check if deploy.sh was copied
if [ -f "$DEPLOY_DIR/deploy.sh" ]; then
    echo "deploy.sh successfully copied to $DEPLOY_DIR"
else
    echo "deploy.sh not found in $DEPLOY_DIR. Exiting..."
    exit 1
fi

# Ensure deploy.sh is executable
chmod +x "$DEPLOY_DIR/deploy.sh" || { echo "Failed to make deploy.sh executable"; exit 1; }

# Navigate to deployment directory
echo "Navigating to deployment directory: $DEPLOY_DIR"
cd "$DEPLOY_DIR" || { echo "Failed to navigate to deployment directory"; exit 1; }

# Find the process ID (PID) of the app running on port 5000
PID=$(lsof -t -i:5000)

# If the process is running, kill it
if [ -n "$PID" ]; then
    echo "Killing process running on port 5000 (PID: $PID)"
    su -c "kill -9 $PID" -s /bin/bash root || { echo "Failed to kill process on port 5000"; exit 1; }
fi

# Stop the pm2 process
echo "Stopping pm2 process"
pm2 stop ecosystem.config.js || echo "No pm2 process running or failed to stop pm2 process"

# Install Node.js dependencies
echo "Installing Node.js dependencies"
npm install || { echo "npm install failed"; exit 1; }

# Start the application using pm2
echo "Starting app with pm2"
pm2 start ecosystem.config.js || { echo "Failed to start app with pm2"; exit 1; }

# Verify if the process is running on port 5000
NEW_PID=$(lsof -t -i:5000)
if [ -n "$NEW_PID" ]; then
    echo "Deployment successful. App running on port 5000 with new PID: $NEW_PID"
else
    echo "Deployment failed. No process running on port 5000."
    exit 1
fi
