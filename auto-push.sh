#!/bin/bash

# Auto-push script untuk GitHub realtime
# Memantau perubahan file dan melakukan auto push ke GitHub

REPO_DIR="/workspaces/hamos"
BRANCH="main"
LOG_FILE="${REPO_DIR}/.auto-push.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to perform auto commit and push
auto_push() {
    cd "$REPO_DIR" || return 1
    
    # Check if there are any changes
    if ! git diff-index --quiet HEAD --; then
        log_message "Perubahan terdeteksi, melakukan commit dan push..."
        
        # Stage all changes
        git add -A
        
        # Create commit with timestamp
        COMMIT_MSG="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$COMMIT_MSG" 2>&1 | tee -a "$LOG_FILE"
        
        # Push to GitHub
        if git push origin "$BRANCH" 2>&1 | tee -a "$LOG_FILE"; then
            log_message "✓ Push ke GitHub berhasil"
        else
            log_message "✗ Gagal push ke GitHub"
        fi
    fi
}

log_message "Auto-push service dimulai..."
log_message "Direktori: $REPO_DIR"
log_message "Branch: $BRANCH"

# Initial push
auto_push

# Gunakan inotifywait untuk memantau perubahan file
if ! command -v inotifywait &> /dev/null; then
    log_message "inotify-tools tidak ditemukan, menggunakan fallback polling mode..."
    
    # Fallback: polling setiap 5 detik
    while true; do
        sleep 5
        auto_push
    done
else
    log_message "Menggunakan inotifywait untuk real-time monitoring..."
    
    # Monitor file changes with inotifywait, exclude .git dan node_modules
    inotifywait -m -r \
        --exclude '(\.git|node_modules|\.vscode|\.next|dist|build)' \
        -e modify,create,delete,move \
        "$REPO_DIR" 2>&1 | while read path action file; do
        
        # Skip if file is in excluded directories
        if [[ "$file" =~ \.(git|vscode|next) ]]; then
            continue
        fi
        
        log_message "File changed: $path$file ($action)"
        auto_push
    done
fi
