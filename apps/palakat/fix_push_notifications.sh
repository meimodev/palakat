#!/bin/bash

# Script to fix push notification setup after configuration changes
# Run this script from the palakat app directory

echo "🔧 Fixing Push Notifications Setup..."
echo ""

# Step 1: Clean build artifacts
echo "1️⃣  Cleaning build artifacts..."
flutter clean

# Step 2: Get dependencies
echo ""
echo "2️⃣  Getting dependencies (including firebase_messaging)..."
flutter pub get

# Step 3: Instructions for user
echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 IMPORTANT: Next steps:"
echo "   1. Uninstall the app from your device/emulator"
echo "   2. Run: flutter run"
echo ""
echo "🔍 After the app starts, check logs for:"
echo "   - [PusherBeamsMobileService] Initialized successfully"
echo "   - [PusherBeamsController] Registering interests..."
echo "   - [PusherBeamsMobileService] ✓ Subscribed to interest: ..."
echo ""
echo "❌ If you still see errors:"
echo "   - Verify PUSHER_BEAMS_INSTANCE_ID in .env"
echo "   - Check internet connectivity"
echo "   - See PUSH_NOTIFICATIONS_TROUBLESHOOTING.md"
