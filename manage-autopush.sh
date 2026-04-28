#!/bin/bash

# Script untuk mengelola auto-push service
# Memudahkan restart, stop, dan monitoring service

REPO_DIR="/workspaces/hamos"
LOG_FILE="${REPO_DIR}/.auto-push.log"
AUTO_PUSH_SCRIPT="${REPO_DIR}/auto-push.sh"

# Function untuk menampilkan status
show_status() {
    echo "=== AUTO-PUSH SERVICE STATUS ==="
    if pgrep -f "auto-push.sh" > /dev/null; then
        echo "Status: ✓ RUNNING"
        echo ""
        echo "Processes:"
        ps aux | grep auto-push | grep -v grep
    else
        echo "Status: ✗ NOT RUNNING"
    fi
}

# Function untuk memulai service
start_service() {
    if pgrep -f "auto-push.sh" > /dev/null; then
        echo "Auto-push service sudah running!"
        return 0
    fi
    
    echo "Memulai auto-push service..."
    nohup "$AUTO_PUSH_SCRIPT" >> "$LOG_FILE" 2>&1 &
    sleep 1
    
    if pgrep -f "auto-push.sh" > /dev/null; then
        echo "✓ Auto-push service berhasil dimulai"
    else
        echo "✗ Gagal memulai auto-push service"
        return 1
    fi
}

# Function untuk menghentikan service
stop_service() {
    if ! pgrep -f "auto-push.sh" > /dev/null; then
        echo "Auto-push service tidak running!"
        return 0
    fi
    
    echo "Menghentikan auto-push service..."
    pkill -f "auto-push.sh"
    
    # Tunggu beberapa saat
    sleep 2
    
    if pgrep -f "auto-push.sh" > /dev/null; then
        echo "✗ Gagal menghentikan service, force killing..."
        pkill -9 -f "auto-push.sh"
    else
        echo "✓ Auto-push service berhasil dihentikan"
    fi
}

# Function untuk restart service
restart_service() {
    stop_service
    sleep 1
    start_service
}

# Function untuk melihat log
show_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "Log file tidak ditemukan: $LOG_FILE"
        return 1
    fi
    
    echo "=== AUTO-PUSH LOGS ==="
    tail -f "$LOG_FILE"
}

# Main command handler
case "${1:-status}" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "Commands:"
        echo "  start     - Mulai auto-push service"
        echo "  stop      - Hentikan auto-push service"
        echo "  restart   - Restart auto-push service"
        echo "  status    - Tampilkan status service"
        echo "  logs      - Tampilkan logs realtime"
        exit 1
        ;;
esac
