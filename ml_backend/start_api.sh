#!/bin/bash

# Ignis Fire Risk API Startup Script
# This script starts the ML backend API server

echo "🔥 Starting Ignis Fire Risk API..."

# Change to the correct directory
cd "$(dirname "$0")"

# Check if the API is already running
if lsof -i :8000 >/dev/null 2>&1; then
    echo "⚠️  API is already running on port 8000"
    echo "🌐 Access at: http://localhost:8000"
    echo "📖 API Docs: http://localhost:8000/docs"
    exit 0
fi

# Start the API server
echo "🚀 Launching API server..."
python3 start_server.py

# If we get here, the server stopped
echo "🛑 API server stopped"
