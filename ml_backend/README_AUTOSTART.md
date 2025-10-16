# Ignis Fire Risk API - Auto-Start Setup Guide

This guide shows you how to set up the Ignis Fire Risk API to start automatically, so you don't have to manually start it every time.

## Quick Start Options

### Option 1: Background Service (Recommended)
Use the background service script for easy control:

```bash
# Start the API in background
./run_api_background.sh start

# Check if it's running
./run_api_background.sh status

# Stop the API
./run_api_background.sh stop

# Restart the API
./run_api_background.sh restart
```

### Option 2: Simple Script
Use the simple startup script:

```bash
# Start the API (will run in foreground)
./start_api.sh
```

### Option 3: macOS LaunchAgent (Auto-start on boot)
Set up the API to start automatically when you log in:

```bash
# Copy the launch agent to the correct location
cp com.ignis.fireapi.plist ~/Library/LaunchAgents/

# Load the launch agent (starts immediately and on every login)
launchctl load ~/Library/LaunchAgents/com.ignis.fireapi.plist

# Check if it's running
launchctl list | grep com.ignis.fireapi

# To stop and disable auto-start:
launchctl unload ~/Library/LaunchAgents/com.ignis.fireapi.plist
```

## API Information

- **URL**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health
- **Model Info**: http://localhost:8000/model/info

## Logs and Troubleshooting

### Background Service Logs
```bash
# View recent logs
tail -f api.log

# View error logs
tail -f api_error.log
```

### LaunchAgent Logs
```bash
# View system logs for the service
log show --predicate 'subsystem contains "com.ignis.fireapi"' --last 1h
```

### Common Issues

1. **Port 8000 already in use**
   ```bash
   # Find what's using port 8000
   lsof -i :8000
   
   # Kill the process if needed
   kill -9 <PID>
   ```

2. **Python not found**
   - Make sure Python 3 is installed: `python3 --version`
   - Update the script paths if needed

3. **Dependencies missing**
   ```bash
   # Reinstall dependencies
   pip3 install -r requirements.txt
   ```

## Rate Limiting Improvements

The weather service now includes:
- **Rate limiting**: Waits between API calls to avoid 429 errors
- **Caching**: Stores weather data for 10 minutes to reduce API calls
- **Fallback data**: Uses reasonable estimates when weather API is unavailable

## Recommended Setup

For development: Use **Option 1** (Background Service)
```bash
./run_api_background.sh start
```

For production/daily use: Use **Option 3** (LaunchAgent)
```bash
cp com.ignis.fireapi.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.ignis.fireapi.plist
```

The API will now start automatically and your iOS app's fire risk map will work without manual intervention!
