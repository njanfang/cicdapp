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

# Step 5: Ensure deploy.sh is executable
chmod +x "$DEPLOY_DIR/deploy.sh" || { echo "Failed to make deploy.sh executable"; exit 1; }

# Step 6: Check deploy.sh permissions
echo "Permissions for deploy.sh:"
ls -la "$DEPLOY_DIR/deploy.sh"

# Step 7: Run deploy.sh using the full path
echo "Running deploy.sh..."
sudo /var/cicdappl/cicdapp/deploy.sh
