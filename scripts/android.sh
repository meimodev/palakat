#!/bin/bash

# Script to run Palakat Flutter app on Android emulator
# Checks if emulator is running, starts one if not, then runs the app

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_DIR="$PROJECT_ROOT/apps/palakat"

# Find Android SDK path
if [ -n "$ANDROID_HOME" ]; then
    ANDROID_SDK="$ANDROID_HOME"
elif [ -n "$ANDROID_SDK_ROOT" ]; then
    ANDROID_SDK="$ANDROID_SDK_ROOT"
elif [ -d "$HOME/Library/Android/sdk" ]; then
    ANDROID_SDK="$HOME/Library/Android/sdk"
else
    echo "❌ Android SDK not found"
    echo "Please set ANDROID_HOME or ANDROID_SDK_ROOT environment variable"
    exit 1
fi

EMULATOR_CMD="$ANDROID_SDK/emulator/emulator"
ADB_CMD="$ANDROID_SDK/platform-tools/adb"

if [ ! -f "$EMULATOR_CMD" ]; then
    echo "❌ Emulator command not found at: $EMULATOR_CMD"
    exit 1
fi

if [ ! -f "$ADB_CMD" ]; then
    echo "❌ ADB command not found at: $ADB_CMD"
    exit 1
fi

echo "🔍 Checking for running Android emulators..."

# Check if any emulator is running
RUNNING_DEVICES=$("$ADB_CMD" devices | grep -w "device" | grep -v "List" | wc -l)

if [ "$RUNNING_DEVICES" -gt 0 ]; then
    echo "✅ Found running emulator"
    DEVICE_NAME=$("$ADB_CMD" devices | grep -w "device" | grep -v "List" | head -n 1 | awk '{print $1}')
    echo "📱 Using device: $DEVICE_NAME"
else
    echo "⚠️  No running emulator found"
    echo "🚀 Starting Android emulator..."
    
    # Get list of available emulators
    AVAILABLE_EMULATORS=$("$EMULATOR_CMD" -list-avds)
    
    if [ -z "$AVAILABLE_EMULATORS" ]; then
        echo "❌ No Android emulators found"
        echo "Please create an emulator using Android Studio AVD Manager"
        exit 1
    fi
    
    # Get first available emulator
    EMULATOR_NAME=$(echo "$AVAILABLE_EMULATORS" | head -n 1)
    echo "📱 Starting emulator: $EMULATOR_NAME"
    
    # Start emulator in background
    "$EMULATOR_CMD" -avd "$EMULATOR_NAME" &
    EMULATOR_PID=$!
    
    echo "⏳ Waiting for emulator to boot..."
    
    # Wait for device to be ready (timeout after 120 seconds)
    TIMEOUT=120
    ELAPSED=0
    while [ $ELAPSED -lt $TIMEOUT ]; do
        BOOT_COMPLETE=$("$ADB_CMD" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
        if [ "$BOOT_COMPLETE" = "1" ]; then
            echo "✅ Emulator is ready"
            break
        fi
        sleep 2
        ELAPSED=$((ELAPSED + 2))
        echo -n "."
    done
    echo ""
    
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "❌ Emulator failed to start within $TIMEOUT seconds"
        exit 1
    fi
    
    # Give it a few more seconds to fully stabilize
    sleep 3
fi

echo "📂 Navigating to app directory: $APP_DIR"
cd "$APP_DIR"

echo "🏃 Running Palakat app..."
flutter run

echo "✅ Done"
