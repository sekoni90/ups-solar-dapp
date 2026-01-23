#!/bin/bash

echo "========================================="
echo "Running UPS Solar App Test Suite"
echo "========================================="

# Run tests with coverage
echo ""
npm run test:report

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✓ All tests passed"
    echo "========================================="
    exit 0
else
    echo ""
    echo "========================================="
    echo "✗ Tests failed"
    echo "========================================="
    exit 1
fi
