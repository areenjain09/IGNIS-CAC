#!/bin/bash

# Ignis Fire Risk API Background Service
# This script starts the API in the background and keeps it running

API_DIR="/Users/areenjain/Documents/Ignis/ml_backend"
PID_FILE="$API_DIR/api.pid"
LOG_FILE="$API_DIR/api.log"

start_api() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "🟢 API is already running (PID: $(cat $PID_FILE))"
        echo "🌐 Access at: http://localhost:8000"
        return 0
    fi
    
    echo "🚀 Starting Ignis Fire Risk API in background..."
    cd "$API_DIR"
    
    # Start the API in background and save PID
    nohup python3 start_server.py > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    
    # Wait a moment and check if it started successfully
    sleep 3
    if kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "✅ API started successfully (PID: $(cat $PID_FILE))"
        echo "🌐 Access at: http://localhost:8000"
        echo "📖 API Docs: http://localhost:8000/docs"
        echo "📝 Logs: $LOG_FILE"
    else
        echo "❌ Failed to start API"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop_api() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "🛑 Stopping API (PID: $(cat $PID_FILE))..."
        kill $(cat "$PID_FILE")
        rm -f "$PID_FILE"
        echo "✅ API stopped"
    else
        echo "⚠️  API is not running"
        rm -f "$PID_FILE" 2>/dev/null
    fi
}

status_api() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "🟢 API is running (PID: $(cat $PID_FILE))"
        echo "🌐 Access at: http://localhost:8000"
    else
        echo "🔴 API is not running"
    fi
}

case "$1" in
    start)
        start_api
        ;;
    stop)
        stop_api
        ;;
    restart)
        stop_api
        sleep 2
        start_api
        ;;
    status)
        status_api
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the API in background"
        echo "  stop    - Stop the API"
        echo "  restart - Restart the API"
        echo "  status  - Check if API is running"
        exit 1
        ;;
esac
