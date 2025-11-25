#!/bin/bash

# Prisma 7 Verification Script
# Verifies that Prisma 7 upgrade is complete and working

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

BACKEND_DIR="apps/palakat_backend"
ERRORS=0

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Prisma 7 Verification                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Check backend directory
if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend directory not found"
    exit 1
fi

cd "$BACKEND_DIR"

print_section "Checking Package Versions"

# Check Prisma version
PRISMA_VERSION=$(pnpm list prisma --depth=0 2>/dev/null | grep prisma | awk '{print $2}' || echo "not found")
if [[ "$PRISMA_VERSION" == 7.* ]]; then
    print_success "Prisma CLI: $PRISMA_VERSION"
else
    print_error "Prisma CLI: $PRISMA_VERSION (expected 7.x)"
    ERRORS=$((ERRORS + 1))
fi

# Check @prisma/client version
CLIENT_VERSION=$(pnpm list @prisma/client --depth=0 2>/dev/null | grep @prisma/client | awk '{print $2}' || echo "not found")
if [[ "$CLIENT_VERSION" == 7.* ]]; then
    print_success "@prisma/client: $CLIENT_VERSION"
else
    print_error "@prisma/client: $CLIENT_VERSION (expected 7.x)"
    ERRORS=$((ERRORS + 1))
fi

# Check adapter
ADAPTER_VERSION=$(pnpm list @prisma/adapter-pg --depth=0 2>/dev/null | grep @prisma/adapter-pg | awk '{print $2}' || echo "not found")
if [[ "$ADAPTER_VERSION" == 7.* ]]; then
    print_success "@prisma/adapter-pg: $ADAPTER_VERSION"
else
    print_error "@prisma/adapter-pg: $ADAPTER_VERSION (expected 7.x)"
    ERRORS=$((ERRORS + 1))
fi

# Check pg
PG_VERSION=$(pnpm list pg --depth=0 2>/dev/null | grep " pg " | awk '{print $2}' || echo "not found")
if [[ "$PG_VERSION" != "not found" ]]; then
    print_success "pg: $PG_VERSION"
else
    print_error "pg: not installed"
    ERRORS=$((ERRORS + 1))
fi

print_section "Checking Configuration Files"

# Check schema.prisma
if [ -f "prisma/schema.prisma" ]; then
    print_success "prisma/schema.prisma exists"
    
    # Check that url is NOT in schema
    if grep -q "url.*=.*env" "prisma/schema.prisma"; then
        print_error "schema.prisma still contains 'url' (should be removed in Prisma 7)"
        ERRORS=$((ERRORS + 1))
    else
        print_success "schema.prisma has no 'url' property (correct for Prisma 7)"
    fi
else
    print_error "prisma/schema.prisma not found"
    ERRORS=$((ERRORS + 1))
fi

# Check prisma.config.ts
if [ -f "prisma/prisma.config.ts" ]; then
    print_success "prisma/prisma.config.ts exists"
    
    # Check content
    if grep -q "datasources" "prisma/prisma.config.ts"; then
        print_success "prisma.config.ts contains datasources config"
    else
        print_error "prisma.config.ts missing datasources config"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_error "prisma/prisma.config.ts not found"
    ERRORS=$((ERRORS + 1))
fi

# Check prisma.service.ts
if [ -f "src/prisma.service.ts" ]; then
    print_success "src/prisma.service.ts exists"
    
    # Check for adapter usage
    if grep -q "PrismaPg" "src/prisma.service.ts" && grep -q "Pool" "src/prisma.service.ts"; then
        print_success "prisma.service.ts uses PostgreSQL adapter"
    else
        print_error "prisma.service.ts missing adapter configuration"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_error "src/prisma.service.ts not found"
    ERRORS=$((ERRORS + 1))
fi

# Check app.module.ts
if [ -f "src/app.module.ts" ]; then
    print_success "src/app.module.ts exists"
    
    # Check for PrismaService
    if grep -q "PrismaService" "src/app.module.ts"; then
        print_success "app.module.ts imports PrismaService"
    else
        print_error "app.module.ts missing PrismaService"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_error "src/app.module.ts not found"
    ERRORS=$((ERRORS + 1))
fi

# Check old generated folder is removed
if [ -d "prisma/generated" ]; then
    print_error "Old prisma/generated folder still exists (should be removed)"
    ERRORS=$((ERRORS + 1))
else
    print_success "Old prisma/generated folder removed"
fi

print_section "Validating Prisma Schema"

if pnpm prisma validate --schema=./prisma/schema.prisma > /dev/null 2>&1; then
    print_success "Schema validation passed"
else
    print_error "Schema validation failed"
    ERRORS=$((ERRORS + 1))
fi

print_section "Checking Prisma Client"

if [ -d "../../node_modules/.pnpm/@prisma+client@7"* ]; then
    print_success "Prisma Client 7.x generated"
else
    print_error "Prisma Client not generated or wrong version"
    print_info "Run: pnpm run prisma:generate"
    ERRORS=$((ERRORS + 1))
fi

print_section "Verification Summary"
echo ""

if [ $ERRORS -eq 0 ]; then
    print_success "All checks passed! Prisma 7 upgrade is complete."
    echo ""
    print_info "Next steps:"
    echo "  1. Start backend: ./scripts/backend-local.sh"
    echo "  2. Test connection: ./scripts/prisma.sh test"
    echo "  3. Open Prisma Studio: ./scripts/prisma.sh studio"
    echo ""
    exit 0
else
    print_error "Found $ERRORS error(s). Please fix them before proceeding."
    echo ""
    print_info "For help, see:"
    echo "  - apps/palakat_backend/PRISMA_7_FINAL_SETUP.md"
    echo "  - apps/palakat_backend/PRISMA_7_UPGRADE.md"
    echo ""
    exit 1
fi
