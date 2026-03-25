#!/bin/bash

NETWORK=$1

if [ -z "$NETWORK" ]; then
    echo "Usage: ./deploy.sh [devnet|testnet|mainnet]"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh devnet   - Deploy to local devnet"
    echo "  ./deploy.sh testnet  - Deploy to Stacks testnet"
    echo "  ./deploy.sh mainnet  - Deploy to Stacks mainnet"
    exit 1
fi

echo "========================================="
echo "Deploying UPS Solar App to $NETWORK"
echo "========================================="

# Validate before deployment
echo ""
echo "Running pre-deployment checks..."
./scripts/build.sh

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Build failed. Aborting deployment."
    exit 1
fi

# Deploy
echo ""
echo "Deploying contracts to $NETWORK..."
clarinet deploy --$NETWORK

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✓ Deployment successful!"
    echo "========================================="
    echo ""
    echo "Next steps:"
    echo "1. Verify deployment on explorer"
    echo "2. Initialize contracts (add installers)"
    echo "3. Test basic functionality"
    echo ""
else
    echo ""
    echo "✗ Deployment failed"
    exit 1
fi
