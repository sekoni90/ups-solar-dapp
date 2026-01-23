#!/bin/bash

echo "========================================="
echo "Building UPS Solar App"
echo "========================================="

# Check contracts
echo ""
echo "Step 1: Validating contracts..."
clarinet check

if [ $? -eq 0 ]; then
    echo "✓ All contracts valid"
else
    echo "✗ Contract validation failed"
    exit 1
fi

# Run tests
echo ""
echo "Step 2: Running tests..."
npm test

if [ $? -eq 0 ]; then
    echo "✓ All tests passed"
else
    echo "✗ Tests failed"
    exit 1
fi

echo ""
echo "========================================="
echo "Build complete!"
echo "========================================="
