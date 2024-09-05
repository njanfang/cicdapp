#!/bin/bash

# Define log file in a writable directory
LOG_FILE="/tmp/deploy.log"
DESTINATION_DIR="/var/cicdappl/cicdapp"
APP_NAME="cicdapp"  # Update this with your actual PM2 app name

# Log starting time
echo "Deployment started at $(date)" >> $LOG_FILE

# Stop the PM2 process
echo "Stopping PM2 process $APP_NAME..." >> $LOG_FILE
pm2 stop $APP_NAME >> $LOG_FILE 2>&1 || echo "PM2 process not found. Skipping stop." >> $LOG_FILE

# Sync project files from Jenkins workspace
echo "Syncing project files..." >> $LOG_FILE
rsync -avz --exclude 'node_modules' /var/lib/jenkins/workspace/cicdappl/ $DESTINATION_DIR >> $LOG_FILE 2>&1

# Change directory to the project path
cd $DESTINATION_DIR || { echo "Failed to change directory to $DESTINATION_DIR" >> $LOG_FILE; exit 1; }

# Install dependencies
echo "Installing dependencies..." >> $LOG_FILE
npm install >> $LOG_FILE 2>&1

# Start or restart the PM2 process
echo "Starting/restarting PM2 process $APP_NAME..." >> $LOG_FILE
pm2 start $APP_NAME >> $LOG_FILE 2>&1 || pm2 restart $APP_NAME >> $LOG_FILE 2>&1

# Log completion time
echo "Deployment finished at $(date)" >> $LOG_FILE
