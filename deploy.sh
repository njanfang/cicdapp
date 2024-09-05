#!/bin/bash

# Define paths
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/cicdappl"
DEPLOY_DIR="/var/cicdappl/cicdapp"

# Step 1: Check Jenkins workspace contents
echo "Checking Jenkins workspace contents:"
ls -la "$JENKINS_WORKSPACE"

# Step 2: Copy files to deployment directory
echo "Copying files to $DEPLOY_DIR..."
cp -r "$JENKINS_WORKSPACE"/* "$DEPLOY_DIR" || { echo "Failed to copy files to $DEPLOY_DIR"; exit 1; }

# Step 3: Verify deploy.sh was copied successfully
if [ -f "$DEPLOY_DIR/deploy.sh" ]; then
    echo "deploy.sh successfully copied to $DEPLOY_DIR"
else
    echo "deploy.sh not found in $DEPLOY_DIR. Exiting..."
    exit 1
fi

# Step 4: Ensure deploy.sh has execute permissions
chmod +x "$DEPLOY_DIR/deploy.sh" || { echo "Failed to make deploy.sh executable"; exit 1; }

# Step 5: Check deploy.sh permissions
echo "Permissions for deploy.sh:"
ls -la "$DEPLOY_DIR/deploy.sh"

# Step 6: Run deploy.sh using full path
echo "Running deploy.sh..."
sudo /var/cicdappl/cicdapp/deploy.sh
