#!/bin/bash

# Define log file in a writable directory
LOG_FILE="/tmp/deploy.log"
DESTINATION_DIR="/var/cicdappl/cicdapp"

# Log starting time
echo "Deployment started at $(date)" >> $LOG_FILE

# List all PM2 processes to log file for reference
echo "Listing PM2 processes..." >> $LOG_FILE
pm2 list >> $LOG_FILE 2>&1

# Stop all PM2 processes (optional: if needed, uncomment this)
# echo "Stopping all PM2 processes..." >> $LOG_FILE
# pm2 stop all >> $LOG_FILE 2>&1

# Sync project files from Jenkins workspace
echo "Syncing project files..." >> $LOG_FILE
rsync -avz --exclude 'node_modules' /var/lib/jenkins/workspace/cicdappl/ $DESTINATION_DIR >> $LOG_FILE 2>&1

# Change directory to the project path
cd $DESTINATION_DIR || { echo "Failed to change directory to $DESTINATION_DIR" >> $LOG_FILE; exit 1; }

# Install dependencies
echo "Installing dependencies..." >> $LOG_FILE
npm install >> $LOG_FILE 2>&1

# Restart all PM2 processes (or start if no processes are running)
echo "Starting/restarting all PM2 processes..." >> $LOG_FILE
pm2 restart all >> $LOG_FILE 2>&1 || pm2 start ecosystem.config.js >> $LOG_FILE 2>&1

# Log completion time
echo "Deployment finished at $(date)" >> $LOG_FILE
