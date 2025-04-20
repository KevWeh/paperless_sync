#!/bin/bash

#########################################################################################
# Script Name	:	paperless_sync
# Description	:	Sync archive documents from Paperless-ngx with mounted archive folder
# Args		:
# Author	:	Kevin Wehrli
# Email		:	-
#########################################################################################

# Variables
PAPERLESS_ARCHIVE_DIR="/opt/paperless/data/media/documents/archive"
PAPERLESS_ARCHIVE_MOUNT="/mnt/archive"

if [ systemctl is-active --quiet docker-*]; then
    rsync -av --delete "$PAPERLESS_ARCHIVE_DIR/" "$PAPERLESS_ARCHIVE_MOUNT/"
    if [ $? -eq 0 ]; then
        echo "Sync completed successfully."
    else
        echo "Sync failed."
    fi
else
    echo "Docker is not running, exiting..."
    exit 1
fi]

