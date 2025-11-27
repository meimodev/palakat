#!/bin/bash

# Script to display SHA1 (and other) certificate fingerprints for Palakat Android app
# Shows both debug and release keystores

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANDROID_DIR="$PROJECT_ROOT/apps/palakat/android"

echo "╔════════════════════════════════════════╗"
echo "║  Palakat Android Certificate Info     ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Function to display keystore info
display_keystore_info() {
    local keystore_path=$1
    local keystore_type=$2
    local keystore_password=$3
    local key_alias=$4

    if [ -f "$keystore_path" ]; then
        echo "📁 $keystore_type Keystore"
        echo "   Path: $keystore_path"
        echo ""

        if [ -n "$keystore_password" ]; then
            # Use provided password
            keytool -list -v -keystore "$keystore_path" -alias "$key_alias" -storepass "$keystore_password" 2>/dev/null | grep -A 5 "Certificate fingerprints" || {
                echo "   ⚠️  Could not read keystore with provided password"
                echo ""
            }
        else
            # Prompt for password
            echo "   Enter keystore password (or press Enter to skip):"
            keytool -list -v -keystore "$keystore_path" -alias "$key_alias" 2>/dev/null | grep -A 5 "Certificate fingerprints" || {
                echo "   ⚠️  Could not read keystore"
                echo ""
            }
        fi
    else
        echo "❌ $keystore_type Keystore not found at: $keystore_path"
        echo ""
    fi
}

# 1. Check for DEBUG keystore (default Android debug keystore)
echo "════════════════════════════════════════"
echo "1️⃣  DEBUG KEYSTORE"
echo "════════════════════════════════════════"
echo ""

DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "📁 Debug Keystore"
    echo "   Path: $DEBUG_KEYSTORE"
    echo ""

    # Get full certificate info
    CERT_INFO=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android 2>/dev/null)

    # Extract SHA1
    SHA1=$(echo "$CERT_INFO" | grep "SHA1:" | awk '{print $2}')
    if [ -n "$SHA1" ]; then
        echo "   ✅ SHA1:"
        echo "   $SHA1"
        echo ""
    fi

    # Extract SHA256
    SHA256=$(echo "$CERT_INFO" | grep "SHA256:" | awk '{print $2}')
    if [ -n "$SHA256" ]; then
        echo "   ✅ SHA256:"
        echo "   $SHA256"
        echo ""
    fi

    # Extract expiration date
    VALID_UNTIL=$(echo "$CERT_INFO" | grep "Valid from:" | sed -n 's/.*until: \(.*\)/\1/p')
    if [ -n "$VALID_UNTIL" ]; then
        echo "   📅 Valid until:"
        echo "   $VALID_UNTIL"
        echo ""
    fi

    # Show all fingerprints for reference
    echo "   All Certificate Fingerprints:"
    echo "$CERT_INFO" | grep -E "(MD5|SHA1|SHA256):" | while read -r line; do
        echo "   $line"
    done
    echo ""
else
    echo "❌ Debug keystore not found at: $DEBUG_KEYSTORE"
    echo "   This is created automatically when you run a debug build."
    echo ""
fi

# 2. Check for RELEASE keystore
echo "════════════════════════════════════════"
echo "2️⃣  RELEASE KEYSTORE"
echo "════════════════════════════════════════"
echo ""

# Check for key.properties file
KEY_PROPERTIES="$ANDROID_DIR/key.properties"
RELEASE_KEYSTORE=""
RELEASE_KEY_ALIAS=""
RELEASE_STORE_PASSWORD=""

if [ -f "$KEY_PROPERTIES" ]; then
    echo "📄 Found key.properties file"

    # Read keystore info from key.properties
    RELEASE_KEYSTORE=$(grep "^storeFile=" "$KEY_PROPERTIES" | cut -d'=' -f2)
    RELEASE_KEY_ALIAS=$(grep "^keyAlias=" "$KEY_PROPERTIES" | cut -d'=' -f2)
    RELEASE_STORE_PASSWORD=$(grep "^storePassword=" "$KEY_PROPERTIES" | cut -d'=' -f2)

    # Handle relative paths
    if [[ ! "$RELEASE_KEYSTORE" = /* ]]; then
        RELEASE_KEYSTORE="$ANDROID_DIR/$RELEASE_KEYSTORE"
    fi

    echo "   Keystore path: $RELEASE_KEYSTORE"
    echo "   Key alias: $RELEASE_KEY_ALIAS"
    echo ""

    if [ -f "$RELEASE_KEYSTORE" ]; then
        # Get full certificate info
        CERT_INFO=$(keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$RELEASE_KEY_ALIAS" -storepass "$RELEASE_STORE_PASSWORD" 2>/dev/null)

        # Extract SHA1
        SHA1=$(echo "$CERT_INFO" | grep "SHA1:" | awk '{print $2}')
        if [ -n "$SHA1" ]; then
            echo "   ✅ SHA1:"
            echo "   $SHA1"
            echo ""
        fi

        # Extract SHA256
        SHA256=$(echo "$CERT_INFO" | grep "SHA256:" | awk '{print $2}')
        if [ -n "$SHA256" ]; then
            echo "   ✅ SHA256:"
            echo "   $SHA256"
            echo ""
        fi

        # Extract expiration date
        VALID_UNTIL=$(echo "$CERT_INFO" | grep "Valid from:" | sed -n 's/.*until: \(.*\)/\1/p')
        if [ -n "$VALID_UNTIL" ]; then
            echo "   📅 Valid until:"
            echo "   $VALID_UNTIL"
            echo ""
        fi

        # Show all fingerprints for reference
        echo "   All Certificate Fingerprints:"
        echo "$CERT_INFO" | grep -E "(MD5|SHA1|SHA256):" | while read -r line; do
            echo "   $line"
        done
        echo ""
    else
        echo "   ❌ Keystore file not found at: $RELEASE_KEYSTORE"
        echo ""
    fi
else
    echo "❌ key.properties file not found at: $KEY_PROPERTIES"
    echo ""

    # Check common locations for release keystore
    COMMON_KEYSTORES=(
        "$ANDROID_DIR/app/upload-keystore.jks"
        "$ANDROID_DIR/app/release-keystore.jks"
        "$ANDROID_DIR/upload-keystore.jks"
        "$ANDROID_DIR/release-keystore.jks"
        "$PROJECT_ROOT/upload-keystore.jks"
        "$PROJECT_ROOT/release-keystore.jks"
    )

    FOUND_KEYSTORE=false
    for keystore in "${COMMON_KEYSTORES[@]}"; do
        if [ -f "$keystore" ]; then
            FOUND_KEYSTORE=true
            echo "   📁 Found keystore at: $keystore"
            echo "   Enter key alias (usually 'upload' or 'key0'):"
            read -r KEY_ALIAS
            echo ""
            echo "   Certificate Fingerprints:"
            keytool -list -v -keystore "$keystore" -alias "$KEY_ALIAS" 2>/dev/null | grep -E "(SHA1|SHA256|MD5):" | while read -r line; do
                echo "   $line"
            done
            echo ""
            break
        fi
    done

    if [ "$FOUND_KEYSTORE" = false ]; then
        echo "   ℹ️  No release keystore found in common locations."
        echo "   You can manually check a keystore by running:"
        echo "   keytool -list -v -keystore /path/to/keystore -alias your_alias"
        echo ""
    else
        # Get full certificate info for found keystore
        CERT_INFO=$(keytool -list -v -keystore "$keystore" -alias "$KEY_ALIAS" 2>/dev/null)

        # Extract SHA1
        SHA1=$(echo "$CERT_INFO" | grep "SHA1:" | awk '{print $2}')
        if [ -n "$SHA1" ]; then
            echo "   ✅ SHA1:"
            echo "   $SHA1"
            echo ""
        fi

        # Extract SHA256
        SHA256=$(echo "$CERT_INFO" | grep "SHA256:" | awk '{print $2}')
        if [ -n "$SHA256" ]; then
            echo "   ✅ SHA256:"
            echo "   $SHA256"
            echo ""
        fi

        # Extract expiration date
        VALID_UNTIL=$(echo "$CERT_INFO" | grep "Valid from:" | sed -n 's/.*until: \(.*\)/\1/p')
        if [ -n "$VALID_UNTIL" ]; then
            echo "   📅 Valid until:"
            echo "   $VALID_UNTIL"
            echo ""
        fi
    fi
fi

# 3. Google Play App Signing Certificate
echo "════════════════════════════════════════"
echo "3️⃣  GOOGLE PLAY APP SIGNING"
echo "════════════════════════════════════════"
echo ""
echo "ℹ️  If you're using Google Play App Signing, you need to get"
echo "   the SHA1 from the Google Play Console:"
echo ""
echo "   1. Go to: https://play.google.com/console"
echo "   2. Select your app"
echo "   3. Go to: Release > Setup > App integrity"
echo "   4. Copy the SHA-1 certificate fingerprint under 'App signing key certificate'"
echo ""

echo "════════════════════════════════════════"
echo "💡 Usage Tips"
echo "════════════════════════════════════════"
echo ""
echo "For Firebase/Google Services configuration:"
echo "  • Add the DEBUG SHA1 for development"
echo "  • Add the RELEASE/Play Store SHA1 for production"
echo "  • You can add both to the same Firebase project"
echo ""
echo "To add SHA1 to Firebase:"
echo "  1. Go to Firebase Console > Project Settings"
echo "  2. Under 'Your apps', select your Android app"
echo "  3. Click 'Add fingerprint' and paste the SHA1"
echo ""
