#!/bin/bash
set -euo pipefail

# ==============================================================================
# Script Name    : paperless_sync.sh
# Description    : Syncs Paperless-ngx archive with mounted SMB archive share
# Author         : Kevin Wehrli
# Last Updated   : 2025-04-21
# Usage          : Called by systemd-timer
# Requirements   : docker, rsync, Paperless-ngx container named "paperless_web"
# ==============================================================================

# ---- Configuration ----
PAPERLESS_ARCHIVE_DIR="/opt/paperless/data/media/documents/archive"
PAPERLESS_ARCHIVE_MOUNT="/mnt/archive"
SERVICE_NAME="paperless_web"
LOG_DIR="/var/log/paperless"
mkdir -p "$LOG_DIR"


# ---- Create new log file per day ----
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d)-sync.log"

# ---- Delete log files older than 7 days ----
find "$LOG_DIR" -name "*-sync.log" -type f -mtime +7 -delete

# ---- Logging functions ----
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    echo "$(timestamp) – $1" >> "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# ---- Main logic ----

# Check if the container is running
if docker inspect -f '{{.State.Running}}' "$SERVICE_NAME" 2>/dev/null | grep -q true; then
    log "Container '$SERVICE_NAME' is running, starting rsync."

    # Run rsync and write output to log
    if rsync -a --delete "$PAPERLESS_ARCHIVE_DIR/" "$PAPERLESS_ARCHIVE_MOUNT/" >> "$LOG_FILE" 2>&1; then
        log "Sync completed successfully."
    else
        error_exit "rsync failed."
    fi
else
    error_exit "Container '$SERVICE_NAME' is not running. No sync performed."
fi
