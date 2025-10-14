#!/bin/bash

# --- Configuration ---
# All script output and notifications will go to this file.
LOG_FILE="${HOME}/repo-sync.log"

# --- Logging Function ---
# Appends a timestamped message to the log file.
log() {
    local level="$1"
    local message="$2"
    # Format: [YYYY-MM-DD HH:MM:SS] LEVEL: Message
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${level}: ${message}" | tee -a "${LOG_FILE}"
}

# --- Zenity Notification Function ---
# Displays a graphical desktop notification if Zenity is available.
# Usage: notify "error" "Title" "Message Body"
# Usage: notify "info" "Title" "Message Body"
notify() {
    local type="$1"
    local title="$2"
    local message="$3"

    if command -v zenity &> /dev/null; then
        zenity --${type} --title="${title}" --text="${message}" --no-wrap &
    else
        log "INFO" "Zenity not found. Skipping graphical notification."
    fi
}

# --- Main Script ---

log "INFO" "Repo sync script started."

# --- Check for required environment variable ---
if [ -z "$GIT_TOKEN" ]; then
    err_msg="GIT_TOKEN environment variable is not set. Aborting."
    log "ERROR" "$err_msg"
    notify "error" "Repo Sync Failed" "$err_msg"
    exit 1
fi

# --- Check for correct number of arguments ---
if [ "$#" -ne 3 ]; then
    err_msg="Usage: $0 <source_url> <dest_url> <repo_name>. Aborting."
    log "ERROR" "$err_msg"
    notify "error" "Repo Sync Failed" "$err_msg"
    exit 1
fi

# --- Configuration from Command-Line Arguments ---
SOURCE_REPO_URL="$1"
DESTINATION_REPO_URL="$2"
REPO_NAME="$3"
LOCAL_MIRROR_DIR="${REPO_NAME}.git"

# --- Create authenticated URLs by injecting the token ---
AUTH_SOURCE_URL="${SOURCE_REPO_URL/https:\/\//https:\/\/$GIT_TOKEN@}"
AUTH_DESTINATION_URL="${DESTINATION_REPO_URL/https:\/\//https:\/\/$GIT_TOKEN@}"


# 1. Check if the local mirror directory exists and update it
if [ ! -d "$LOCAL_MIRROR_DIR" ]; then
    log "INFO" "Local mirror not found for '$REPO_NAME'. Performing initial clone."
    # Redirect git output to the log file
    git clone --mirror "$AUTH_SOURCE_URL" "$LOCAL_MIRROR_DIR" >> "${LOG_FILE}" 2>&1

    if [ $? -ne 0 ]; then
        err_msg="Failed to clone the source repository: $REPO_NAME. Check log for details."
        log "ERROR" "$err_msg"
        notify "error" "Repo Sync Failed" "$err_msg"
        exit 1
    fi
else
    log "INFO" "Local mirror found for '$REPO_NAME'. Fetching updates."
    cd "$LOCAL_MIRROR_DIR"
    
    log "INFO" "Updating remote URL to use the token."
    git remote set-url origin "$AUTH_SOURCE_URL" >> "${LOG_FILE}" 2>&1

    git fetch --all --prune >> "${LOG_FILE}" 2>&1
    if [ $? -ne 0 ]; then
        err_msg="Failed to fetch updates for repository: $REPO_NAME. Check log for details."
        log "ERROR" "$err_msg"
        notify "error" "Repo Sync Failed" "$err_msg"
        cd ..
        exit 1
    fi
    cd ..
fi

# 2. Navigate into the repository directory to push
log "INFO" "Entering directory '$LOCAL_MIRROR_DIR' to begin push."
cd "$LOCAL_MIRROR_DIR"

if [ $? -ne 0 ]; then
    err_msg="Could not enter the local mirror directory: $LOCAL_MIRROR_DIR"
    log "ERROR" "$err_msg"
    notify "error" "Repo Sync Failed" "$err_msg"
    exit 1
fi

# 3. Push all branches and tags to the new destination explicitly
log "INFO" "Pushing all branches to the destination for '$REPO_NAME'."
git push --all "$AUTH_DESTINATION_URL" >> "${LOG_FILE}" 2>&1

if [ $? -ne 0 ]; then
    err_msg="Failed to push branches for repository: $REPO_NAME. Check log for details."
    log "ERROR" "$err_msg"
    notify "error" "Repo Sync Failed" "$err_msg"
    cd ..
    exit 1
fi

log "INFO" "Pushing all tags to the destination for '$REPO_NAME'."
git push --tags "$AUTH_DESTINATION_URL" >> "${LOG_FILE}" 2>&1

if [ $? -ne 0 ]; then
    err_msg="Failed to push tags for repository: $REPO_NAME. Check log for details."
    log "ERROR" "$err_msg"
    notify "error" "Repo Sync Failed" "$err_msg"
    cd ..
    exit 1
fi

# 4. Go back to the original directory
cd ..

# --- Success Notification ---
success_msg="Repository '$REPO_NAME' was synchronized successfully."
log "INFO" "$success_msg"
notify "info" "Repo Sync Successful" "$success_msg"
