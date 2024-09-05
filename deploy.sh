#!/bin/bash

# Define paths
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"
DEPLOY_DIR="/var/cicdappl/cicdapp"

# Step 1: Copy files from Jenkins workspace to the deployment directory
echo "Copying files to $DEPLOY_DIR..."
cp -r "$JENKINS_WORKSPACE"/* "$DEPLOY_DIR" || { echo "Failed to copy files to $DEPLOY_DIR"; exit 1; }

# Step 2: Check if deploy.sh was copied successfully
if [ -f "$DEPLOY_DIR/deploy.sh" ]; then
    echo "deploy.sh successfully copied."
else
    echo "deploy.sh not found. Exiting..."
    exit 1
fi

# Step 3: Ensure deploy.sh is executable
chmod +x "$DEPLOY_DIR/deploy.sh" || { echo "Failed to make deploy.sh executable"; exit 1; }

# Step 4: Navigate to deployment directory
cd "$DEPLOY_DIR" || { echo "Failed to navigate to $DEPLOY_DIR"; exit 1; }

# Step 5: Find and kill any process running on port 5000
PID=$(lsof -t -i:5000)
if [ -n "$PID" ]; then
    echo "Killing process on port 5000 (PID: $PID)"
    su -c "kill -9 $PID" -s /bin/bash root || { echo "Failed to kill process"; exit 1; }
fi

# Step 6: Stop the pm2 process
pm2 stop ecosystem.config.js || echo "No pm2 process running"

# Step 7: Install Node.js dependencies
npm install || { echo "npm install failed"; exit 1; }

# Step 8: Start the app with pm2
pm2 start ecosystem.config.js || { echo "Failed to start app with pm2"; exit 1; }

# Step 9: Output the success message
NEW_PID=$(lsof -t -i:5000)
if [ -n "$NEW_PID" ]; then
    echo "Deployment successful. App running on port 5000 with new PID: $NEW_PID"
else
    echo "Deployment failed."
    exit 1
fi
