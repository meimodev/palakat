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

echo "🔍 Checking for available Android devices..."

# Get list of running devices
RUNNING_DEVICES=$("$ADB_CMD" devices | grep -w "device" | grep -v "List" | awk '{print $1}')
RUNNING_COUNT=$(echo "$RUNNING_DEVICES" | grep -c . || true)

# Get list of available emulators (not running)
AVAILABLE_EMULATORS=$("$EMULATOR_CMD" -list-avds)

# Build arrays for devices and their display names
declare -a DEVICE_LIST
declare -a DEVICE_IDS
OPTION_NUM=1

echo ""
echo "📱 Available devices:"
echo ""

# Add running devices first
if [ -n "$RUNNING_DEVICES" ]; then
    while IFS= read -r device_id; do
        if [[ "$device_id" == emulator-* ]]; then
            # Get emulator name
            DEVICE_MODEL=$("$ADB_CMD" -s "$device_id" emu avd name 2>/dev/null || echo "Unknown Emulator")
            echo "   $OPTION_NUM) 🖥️  $DEVICE_MODEL [$device_id] (Running)"
        else
            # Get physical device model
            DEVICE_MODEL=$("$ADB_CMD" -s "$device_id" shell getprop ro.product.model 2>/dev/null | tr -d '\r' || echo "Unknown Device")
            echo "   $OPTION_NUM) 📱 $DEVICE_MODEL [$device_id] (Connected)"
        fi
        DEVICE_LIST+=("$device_id")
        DEVICE_IDS+=("running")
        OPTION_NUM=$((OPTION_NUM + 1))
    done <<< "$RUNNING_DEVICES"
fi

# Add available emulators that are not running
if [ -n "$AVAILABLE_EMULATORS" ]; then
    while IFS= read -r avd_name; do
        # Check if this emulator is already running
        IS_RUNNING=false
        if [ -n "$RUNNING_DEVICES" ]; then
            while IFS= read -r running_device; do
                if [[ "$running_device" == emulator-* ]]; then
                    RUNNING_AVD=$("$ADB_CMD" -s "$running_device" emu avd name 2>/dev/null | tr -d '\r')
                    if [ "$RUNNING_AVD" = "$avd_name" ]; then
                        IS_RUNNING=true
                        break
                    fi
                fi
            done <<< "$RUNNING_DEVICES"
        fi

        if [ "$IS_RUNNING" = false ]; then
            echo "   $OPTION_NUM) 🖥️  $avd_name (Start Emulator)"
            DEVICE_LIST+=("$avd_name")
            DEVICE_IDS+=("start")
            OPTION_NUM=$((OPTION_NUM + 1))
        fi
    done <<< "$AVAILABLE_EMULATORS"
fi

echo ""

# Check if any devices are available
TOTAL_OPTIONS=$((OPTION_NUM - 1))
if [ "$TOTAL_OPTIONS" -eq 0 ]; then
    echo "❌ No devices available"
    echo "Please either:"
    echo "   - Connect an Android device via USB and enable USB debugging"
    echo "   - Create an emulator using Android Studio AVD Manager"
    exit 1
fi

# Ask user to choose
read -p "❓ Select a device (1-$TOTAL_OPTIONS): " CHOICE

# Validate choice
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "$TOTAL_OPTIONS" ]; then
    echo "❌ Invalid choice. Please run the script again and select a number between 1 and $TOTAL_OPTIONS"
    exit 1
fi

# Get selected device
SELECTED_INDEX=$((CHOICE - 1))
SELECTED_DEVICE="${DEVICE_LIST[$SELECTED_INDEX]}"
SELECTED_TYPE="${DEVICE_IDS[$SELECTED_INDEX]}"

DEVICE_ID=""

if [ "$SELECTED_TYPE" = "running" ]; then
    # Device is already running
    echo "✅ Using device: $SELECTED_DEVICE"
    DEVICE_ID="$SELECTED_DEVICE"
elif [ "$SELECTED_TYPE" = "start" ]; then
    # Need to start the emulator
    echo "🚀 Starting emulator: $SELECTED_DEVICE"

    # Start emulator in background
    "$EMULATOR_CMD" -avd "$SELECTED_DEVICE" &
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

    # Get the emulator device ID
    NEW_DEVICE=$("$ADB_CMD" devices | grep -w "device" | grep "emulator-" | head -n 1 | awk '{print $1}')
    if [ -n "$NEW_DEVICE" ]; then
        DEVICE_ID="$NEW_DEVICE"
    fi
fi

echo "📂 Navigating to app directory: $APP_DIR"
cd "$APP_DIR"

echo "🏃 Running Palakat app on device: $DEVICE_ID"
flutter run -d "$DEVICE_ID"

echo "✅ Done"
