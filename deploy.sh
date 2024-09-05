#!/bin/bash

# Set log file path where Jenkins has write access
LOG_FILE="/tmp/deploy.log"
DESTINATION_DIR="/var/cicdappl/cicdapp"
APP_NAME="your_actual_app_name"  # Update this to the actual app name

# Start logging
echo "Deployment started at $(date)" >> $LOG_FILE

# Stop the PM2 process
echo "Stopping the PM2 process..." >> $LOG_FILE
pm2 stop $APP_NAME || echo "PM2 process not running, skipping stop..." >> $LOG_FILE

# Sync project files
echo "Syncing project files..." >> $LOG_FILE
rsync -avz --exclude 'node_modules' /var/lib/jenkins/workspace/cicdappl/ $DESTINATION_DIR >> $LOG_FILE 2>&1

# Change to the destination directory
cd $DESTINATION_DIR || { echo "Failed to change directory to $DESTINATION_DIR" >> $LOG_FILE; exit 1; }

# Install dependencies
echo "Installing dependencies..." >> $LOG_FILE
npm install >> $LOG_FILE 2>&1

# Restart the PM2 process
echo "Restarting the PM2 process..." >> $LOG_FILE
pm2 start $APP_NAME || pm2 restart $APP_NAME >> $LOG_FILE 2>&1

# Log completion
echo "Deployment finished at $(date)" >> $LOG_FILE
