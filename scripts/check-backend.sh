#!/bin/bash

# Check if backend is accessible
# This script helps diagnose connectivity issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}${1}${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

# Default values
BACKEND_URL="http://192.168.0.130:3000"
API_VERSION="api/v1"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            BACKEND_URL="$2"
            shift 2
            ;;
        --version)
            API_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Check if the backend is accessible"
            echo ""
            echo "Options:"
            echo "  --url URL         Backend URL (default: http://192.168.0.130:3000)"
            echo "  --version PATH    API version path (default: api/v1)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Backend Connectivity Check          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

print_section "Checking Backend Connection"

FULL_URL="${BACKEND_URL}/${API_VERSION}"
print_info "Testing connection to: $FULL_URL"
echo ""

# Check if curl is available
if ! command -v curl &> /dev/null; then
    print_error "curl is not installed"
    print_info "Please install curl to use this script"
    exit 1
fi

# Test basic connectivity
print_info "Testing basic connectivity..."
if curl -s --connect-timeout 5 "${BACKEND_URL}" > /dev/null 2>&1; then
    print_success "Backend server is reachable at $BACKEND_URL"
else
    print_error "Cannot connect to backend at $BACKEND_URL"
    echo ""
    print_info "Possible issues:"
    echo "  1. Backend is not running"
    echo "  2. Wrong IP address or port"
    echo "  3. Firewall blocking the connection"
    echo "  4. Network connectivity issues"
    echo ""
    print_info "To start the backend, run:"
    echo "  ./scripts/backend-local.sh"
    echo ""
    exit 1
fi

# Test API endpoint
print_info "Testing API endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${FULL_URL}/auth/sign-in" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{}' 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "000" ]; then
    print_error "Failed to reach API endpoint"
    print_info "The server is reachable but the API endpoint is not responding"
elif [ "$HTTP_CODE" = "400" ] || [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "404" ]; then
    print_success "API endpoint is responding (HTTP $HTTP_CODE)"
    print_info "This is expected - the endpoint requires valid credentials"
else
    print_success "API endpoint is responding (HTTP $HTTP_CODE)"
fi

echo ""
print_section "Connection Summary"
echo ""
print_success "Backend URL: $BACKEND_URL"
print_success "API Version: $API_VERSION"
print_success "Full API URL: $FULL_URL"
echo ""

# Check CORS headers
print_info "Checking CORS headers..."
CORS_HEADERS=$(curl -s -I -X OPTIONS "${FULL_URL}/auth/sign-in" \
    -H "Origin: http://localhost:8080" \
    -H "Access-Control-Request-Method: POST" 2>/dev/null | grep -i "access-control" || echo "")

if [ -n "$CORS_HEADERS" ]; then
    print_success "CORS is enabled"
    echo "$CORS_HEADERS"
else
    print_error "CORS headers not found"
    print_info "This might cause issues with web applications"
fi

echo ""
print_info "If you're still having connection issues from the Flutter web app:"
echo "  1. Make sure the backend is running: ./scripts/backend-local.sh"
echo "  2. Check your .env file has the correct URL"
echo "  3. Try using 'localhost' instead of the IP address if running locally"
echo "  4. Check browser console for detailed error messages"
echo ""
