#!/bin/bash

# Navigate to Jenkins workspace directory
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"
DEPLOY_DIR="/var/cicdappl/cicdapp"

# Ensure the script is being run from the correct directory
cd "$JENKINS_WORKSPACE" || { echo "Failed to navigate to Jenkins workspace"; exit 1; }

# Copy files from Jenkins workspace to the deployment directory
echo "Copying files to $DEPLOY_DIR..."
cp -r * "$DEPLOY_DIR" || { echo "Failed to copy files to $DEPLOY_DIR"; exit 1; }

# Verify that deploy.sh was copied correctly
if [ ! -f "$DEPLOY_DIR/deploy.sh" ]; then
    echo "deploy.sh not found in $DEPLOY_DIR. Exiting..."
    exit 1
fi

# Ensure deploy.sh has execute permissions
chmod +x "$DEPLOY_DIR/deploy.sh"

# Navigate to the deployment directory
cd "$DEPLOY_DIR" || { echo "Failed to navigate to $DEPLOY_DIR"; exit 1; }

# Find the process ID (PID) of the app running on port 5000
PID=$(lsof -t -i:5000)

# If the process is running, kill it
if [ -n "$PID" ]; then
  su -c "kill -9 $PID" -s /bin/bash root || { echo "Failed to kill process on port 5000"; exit 1; }
fi

# Stop the pm2 process (if running)
pm2 stop ecosystem.config.js || echo "No pm2 process running or failed to stop pm2 process"

# Install Node.js dependencies
npm install || { echo "npm install failed"; exit 1; }

# Start the application using pm2
pm2 start ecosystem.config.js || { echo "Failed to start app with pm2"; exit 1; }

# Output success message with PID of new instance
NEW_PID=$(lsof -t -i:5000)
if [ -n "$NEW_PID" ]; then
  echo "Deployment successful. Running on port 5000 with new PID: $NEW_PID"
else
  echo "Deployment failed. No process running on port 5000."
  exit 1
fi
