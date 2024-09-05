#!/bin/bash

# Directory variables
SOURCE_DIR="/path/to/source"
DESTINATION_DIR="/path/to/project"

# Logging
LOG_FILE="/var/log/deploy.log"
echo "Deployment started at $(date)" >> $LOG_FILE

# Stop the application using PM2
echo "Stopping the existing PM2 process..." >> $LOG_FILE
pm2 stop app_name || echo "PM2 process not running, skipping stop..." >> $LOG_FILE

# Sync files from source to destination
echo "Syncing files from $SOURCE_DIR to $DESTINATION_DIR" >> $LOG_FILE
rsync -av --exclude 'node_modules' --exclude '.git' "$SOURCE_DIR/" "$DESTINATION_DIR/" >> $LOG_FILE 2>&1

# Install dependencies
echo "Installing Node.js dependencies..." >> $LOG_FILE
cd "$DESTINATION_DIR" || exit
npm install >> $LOG_FILE 2>&1

# Start the application using PM2
echo "Starting the application using PM2..." >> $LOG_FILE
pm2 start app_name || pm2 start index.js --name app_name >> $LOG_FILE 2>&1

# Confirm the process is running
echo "Deployment finished at $(date)" >> $LOG_FILE
pm2 status app_name >> $LOG_FILE

# Exit script
exit 0
