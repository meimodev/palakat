#!/bin/bash

# =============================================================================
# Firebase Storage CORS Setup Script
# =============================================================================
#
# This script configures CORS for your Firebase Storage bucket to allow
# Flutter Web apps to load images directly from signed URLs.
#
# Prerequisites:
#   1. Google Cloud SDK (gcloud) installed: https://cloud.google.com/sdk/docs/install
#   2. gsutil command available (included with gcloud)
#   3. Authenticated with: gcloud auth login
#   4. Project set with: gcloud config set project YOUR_PROJECT_ID
#
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Firebase Storage CORS Setup${NC}"
echo "================================"
echo ""

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    echo -e "${RED}Error: gsutil is not installed.${NC}"
    echo ""
    echo "Please install Google Cloud SDK:"
    echo "  macOS:   brew install google-cloud-sdk"
    echo "  or visit: https://cloud.google.com/sdk/docs/install"
    echo ""
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with Google Cloud.${NC}"
    echo ""
    echo "Please run: gcloud auth login"
    echo ""
    exit 1
fi

# Get bucket name from argument or prompt
BUCKET_NAME="$1"

if [ -z "$BUCKET_NAME" ]; then
    echo "Enter your Firebase Storage bucket name"
    echo "(Usually: your-project-id.appspot.com)"
    echo ""
    read -p "Bucket name: " BUCKET_NAME
fi

if [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}Error: Bucket name is required.${NC}"
    exit 1
fi

# Path to CORS config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORS_FILE="$SCRIPT_DIR/../apps/palakat_backend/cors.json"

if [ ! -f "$CORS_FILE" ]; then
    echo -e "${RED}Error: CORS config file not found at $CORS_FILE${NC}"
    exit 1
fi

echo ""
echo "Bucket: gs://$BUCKET_NAME"
echo "CORS config: $CORS_FILE"
echo ""

# Show current CORS config
echo -e "${YELLOW}Current CORS configuration:${NC}"
gsutil cors get "gs://$BUCKET_NAME" 2>/dev/null || echo "(No CORS configured)"
echo ""

# Apply new CORS config
echo -e "${YELLOW}Applying new CORS configuration...${NC}"
gsutil cors set "$CORS_FILE" "gs://$BUCKET_NAME"

echo ""
echo -e "${GREEN}✓ CORS configuration applied successfully!${NC}"
echo ""

# Verify
echo -e "${YELLOW}Verifying new CORS configuration:${NC}"
gsutil cors get "gs://$BUCKET_NAME"

echo ""
echo -e "${GREEN}Done! Your Flutter Web app should now be able to load images from Firebase Storage.${NC}"
echo ""
echo "Note: It may take a few minutes for the changes to propagate."
