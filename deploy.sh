#!/bin/bash

# Define paths
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"
DEPLOY_DIR="/var/cicdappl/cicdapp"

# Step 1: Display contents of Jenkins workspace
echo "Listing contents of Jenkins workspace ($JENKINS_WORKSPACE):"
ls -la "$JENKINS_WORKSPACE"

# Step 2: Copy files to the deployment directory
echo "Copying files from Jenkins workspace to $DEPLOY_DIR"
cp -r "$JENKINS_WORKSPACE"/* "$DEPLOY_DIR" || { echo "Failed to copy files to $DEPLOY_DIR"; exit 1; }

# Step 3: Display contents of the deployment directory
echo "Listing contents of deployment directory ($DEPLOY_DIR):"
ls -la "$DEPLOY_DIR"

# Step 4: Check if deploy.sh exists in the deployment directory
if [ -f "$DEPLOY_DIR/deploy.sh" ]; then
    echo "deploy.sh successfully copied to $DEPLOY_DIR"
else
    echo "deploy.sh not found in $DEPLOY_DIR. Exiting..."
    exit 1
fi

# Step 5: Ensure deploy.sh has execute permissions
chmod +x "$DEPLOY_DIR/deploy.sh" || { echo "Failed to make deploy.sh executable"; exit 1; }

# Step 6: Check permissions of deploy.sh
echo "Permissions for deploy.sh:"
ls -la "$DEPLOY_DIR/deploy.sh"

# Step 7: Run deploy.sh directly
echo "Running deploy.sh..."
/var/cicdappl/cicdapp/deploy.sh

# Step 8: Check for processes running on port 5000 and kill them
echo "Checking for existing processes on port 5000..."
PID=$(lsof -t -i:5000)
if [ -n "$PID" ]; then
    echo "Killing existing process on port 5000 (PID: $PID)"
    sudo kill -9 "$PID" || { echo "Failed to kill process on port 5000"; exit 1; }
else
    echo "No existing process found on port 5000"
fi

# Step 9: Stop the pm2 process if running
echo "Stopping any existing pm2 processes..."
pm2 stop ecosystem.config.js || echo "No pm2 process running"

# Step 10: Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install || { echo "npm install failed"; exit 1; }

# Step 11: Start the app with pm2
echo "Starting the app with pm2..."
pm2 start ecosystem.config.js || pm2 start index.js --name "cicdappl"

# Step 12: Check if the app is running on port 5000
echo "Checking if the app is running on port 5000..."
NEW_PID=$(lsof -t -i:5000)
if [ -n "$NEW_PID" ]; then
    echo "Deployment successful. App running on port 5000 with PID: $NEW_PID"
else
    echo "Deployment failed. No process running on port 5000."
    echo "Displaying pm2 logs for troubleshooting:"
    pm2 logs cicdappl  # Display pm2 logs for troubleshooting
    exit 1
fi
