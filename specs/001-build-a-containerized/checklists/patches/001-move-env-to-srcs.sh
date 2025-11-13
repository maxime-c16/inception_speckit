#!/bin/bash
# Patch 001: Move .env to srcs/ directory for strict subject compliance
# Issue: CHK005 - .env should be in srcs/ per subject requirements

set -e

echo "=========================================="
echo "Patch 001: Move .env to srcs/"
echo "=========================================="
echo ""

# Check if running from project root
if [ ! -f "Makefile" ]; then
    echo "❌ Error: Must run from project root (where Makefile is located)"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found at project root"
    exit 1
fi

echo "Step 1: Creating backup..."
cp .env .env.backup
echo "✅ Created backup: .env.backup"
echo ""

echo "Step 2: Copying .env to srcs/..."
cp .env srcs/.env
echo "✅ Copied .env to srcs/.env"
echo ""

echo "Step 3: Updating Makefile..."
if grep -q "\-\-env-file \.env" Makefile; then
    # Create backup of Makefile
    cp Makefile Makefile.backup
    
    # Update all occurrences
    sed -i 's/--env-file \.env/--env-file srcs\/.env/g' Makefile
    
    echo "✅ Updated Makefile to use srcs/.env"
    echo "   Changed: --env-file .env → --env-file srcs/.env"
else
    echo "⚠️  Makefile doesn't contain '--env-file .env'"
    echo "   Manual update may be required"
fi
echo ""

echo "Step 4: Updating .gitignore..."
if [ -f ".gitignore" ]; then
    cp .gitignore .gitignore.backup
    
    if grep -q "^\.env$" .gitignore; then
        # Add srcs/.env to gitignore
        if ! grep -q "^srcs/\.env$" .gitignore; then
            sed -i '/^\.env$/a srcs/.env' .gitignore
            echo "✅ Added srcs/.env to .gitignore"
        else
            echo "ℹ️  srcs/.env already in .gitignore"
        fi
    fi
else
    echo "⚠️  No .gitignore file found"
fi
echo ""

echo "Step 5: Verification..."
if [ -f "srcs/.env" ]; then
    echo "✅ srcs/.env exists"
else
    echo "❌ srcs/.env not found"
    exit 1
fi

if grep -q "srcs/\.env" Makefile; then
    echo "✅ Makefile references srcs/.env"
else
    echo "⚠️  Makefile may need manual update"
fi
echo ""

echo "=========================================="
echo "Patch applied successfully!"
echo "=========================================="
echo ""
echo "Backups created:"
echo "  - .env.backup"
echo "  - Makefile.backup (if updated)"
echo "  - .gitignore.backup (if updated)"
echo ""
echo "Next steps:"
echo "  1. Review changes: diff Makefile Makefile.backup"
echo "  2. Test the system: make down && make up"
echo "  3. Verify all services start correctly"
echo ""
echo "To rollback:"
echo "  mv .env.backup .env"
echo "  mv Makefile.backup Makefile"
echo "  rm srcs/.env"
