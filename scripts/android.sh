#!/bin/bash

# Script to run Palakat Flutter app on Android emulator
# Checks if emulator is running, starts one if not, then runs the app

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_DIR="$PROJECT_ROOT/apps/palakat"
ENV_UTILS="$SCRIPT_DIR/env_utils.sh"
SELECTED_ENV="local"

# shellcheck disable=SC1090
source "$ENV_UTILS"

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Run the Palakat mobile app on Android"
    echo ""
    echo "Options:"
    echo "  --env ENVIRONMENT  Environment to use (local, staging, production)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 --env staging"
    echo "  $0 --env production"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            if [[ -z "$2" ]]; then
                echo "❌ Missing value for --env"
                show_help
                exit 1
            fi

            if ! is_supported_env_name "$2"; then
                echo "❌ Unsupported environment: $2"
                echo "Supported environments: $(supported_env_names_text)"
                exit 1
            fi

            SELECTED_ENV="$(normalize_env_name "$2")"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

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

check_env_file() {
    echo "🔍 Checking environment configuration for '$SELECTED_ENV'..."

    if [ ! -f "$APP_DIR/.env" ]; then
        echo "⚠️  .env file not found"

        if [ -f "$APP_DIR/.env.example" ]; then
            echo "ℹ️  Copying .env.example to .env..."
            cp "$APP_DIR/.env.example" "$APP_DIR/.env"
            echo "✅ .env file created"
            echo "⚠️  Please review and update apps/palakat/.env"
        else
            echo "❌ .env.example not found"
            exit 1
        fi
    fi

    local active_env_file
    active_env_file="$(create_temp_env_file "palakat_mobile_${SELECTED_ENV}")"

    if ! extract_env_section_to_file "$APP_DIR/.env" "$SELECTED_ENV" "$active_env_file"; then
        local status=$?
        rm -f "$active_env_file"

        if [ $status -eq 2 ]; then
            echo "❌ Environment '$SELECTED_ENV' is not defined in $APP_DIR/.env"
        else
            echo "❌ Failed to read $APP_DIR/.env"
        fi
        exit 1
    fi

    local missing_keys
    missing_keys="$(missing_env_keys_text "$active_env_file" API_BASE_URL API_BASE_VERSION)"
    rm -f "$active_env_file"

    if [ -n "$missing_keys" ]; then
        echo "❌ Selected environment '$SELECTED_ENV' is missing required variables: $missing_keys"
        exit 1
    fi

    echo "✅ Environment '$SELECTED_ENV' is configured"
}

check_env_file

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
            DEVICE_MODEL=$("$ADB_CMD" -s "$device_id" emu avd name 2>/dev/null || echo "Unknown Emulator")
            echo "   $OPTION_NUM) 🖥️  $DEVICE_MODEL [$device_id] (Running)"
        else
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

TOTAL_OPTIONS=$((OPTION_NUM - 1))
if [ "$TOTAL_OPTIONS" -eq 0 ]; then
    echo "❌ No devices available"
    echo "Please either:"
    echo "   - Connect an Android device via USB and enable USB debugging"
    echo "   - Create an emulator using Android Studio AVD Manager"
    exit 1
fi

read -p "❓ Select a device (1-$TOTAL_OPTIONS): " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "$TOTAL_OPTIONS" ]; then
    echo "❌ Invalid choice. Please run the script again and select a number between 1 and $TOTAL_OPTIONS"
    exit 1
fi

SELECTED_INDEX=$((CHOICE - 1))
SELECTED_DEVICE="${DEVICE_LIST[$SELECTED_INDEX]}"
SELECTED_TYPE="${DEVICE_IDS[$SELECTED_INDEX]}"

DEVICE_ID=""

if [ "$SELECTED_TYPE" = "running" ]; then
    echo "✅ Using device: $SELECTED_DEVICE"
    DEVICE_ID="$SELECTED_DEVICE"
elif [ "$SELECTED_TYPE" = "start" ]; then
    echo "🚀 Starting emulator: $SELECTED_DEVICE"

    "$EMULATOR_CMD" -avd "$SELECTED_DEVICE" &
    EMULATOR_PID=$!

    echo "⏳ Waiting for emulator to boot..."

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

    sleep 3

    NEW_DEVICE=$("$ADB_CMD" devices | grep -w "device" | grep "emulator-" | head -n 1 | awk '{print $1}')
    if [ -n "$NEW_DEVICE" ]; then
        DEVICE_ID="$NEW_DEVICE"
    fi
fi

echo "📂 Navigating to app directory: $APP_DIR"
cd "$APP_DIR"

FLUTTER_CMD=(flutter run -d "$DEVICE_ID" --dart-define="PALAKAT_ENV=$SELECTED_ENV")
if command -v fvm &> /dev/null && [ -f ".fvmrc" ]; then
    FLUTTER_CMD=(fvm "${FLUTTER_CMD[@]}")
    echo "ℹ️  Using FVM for Flutter"
fi

echo "🌐 Using environment: $SELECTED_ENV"
echo "🏃 Running Palakat app on device: $DEVICE_ID"
"${FLUTTER_CMD[@]}"

echo "✅ Done"
