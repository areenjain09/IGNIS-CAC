#!/bin/bash

# Ignis Fire Risk API - Quick Start Script
# Place this in your project root for easy access

echo "🔥 Ignis Fire Risk API Manager"
echo "=============================="

cd "$(dirname "$0")/ml_backend"

case "${1:-start}" in
    start)
        ./run_api_background.sh start
        ;;
    stop)
        ./run_api_background.sh stop
        ;;
    restart)
        ./run_api_background.sh restart
        ;;
    status)
        ./run_api_background.sh status
        ;;
    logs)
        echo "📝 Recent API logs:"
        echo "=================="
        tail -20 api.log
        ;;
    setup-auto)
        echo "🔧 Setting up auto-start on login..."
        cp com.ignis.fireapi.plist ~/Library/LaunchAgents/
        launchctl load ~/Library/LaunchAgents/com.ignis.fireapi.plist
        echo "✅ API will now start automatically on login"
        ;;
    remove-auto)
        echo "🗑️  Removing auto-start..."
        launchctl unload ~/Library/LaunchAgents/com.ignis.fireapi.plist 2>/dev/null || true
        rm -f ~/Library/LaunchAgents/com.ignis.fireapi.plist
        echo "✅ Auto-start removed"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|setup-auto|remove-auto}"
        echo ""
        echo "Commands:"
        echo "  start      - Start the API in background"
        echo "  stop       - Stop the API"
        echo "  restart    - Restart the API"
        echo "  status     - Check if API is running"
        echo "  logs       - Show recent API logs"
        echo "  setup-auto - Set up auto-start on login"
        echo "  remove-auto- Remove auto-start"
        echo ""
        echo "🌐 API URL: http://localhost:8000"
        echo "📖 API Docs: http://localhost:8000/docs"
        ;;
esac
