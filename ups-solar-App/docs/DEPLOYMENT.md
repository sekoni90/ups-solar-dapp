# Deployment Guide

## Overview

This guide covers deploying the UPS Solar App smart contracts to Devnet, Testnet, and Mainnet environments.

## Prerequisites

### Required Tools

- **Clarinet**: Version 3.8 or higher
- **Node.js**: Version 18 or higher
- **Stacks CLI**: Latest version
- **Stacks Wallet**: For Testnet/Mainnet deployments

### Installation

```bash
# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/download/v3.8.0/clarinet-windows-x64.exe -o clarinet.exe

# Install Stacks CLI
npm install -g @stacks/cli

# Verify installations
clarinet --version
stacks-cli --version
```

## Environment Configuration

### Network Settings

The project includes configuration files for each network:

```
settings/
├── Devnet.toml    # Local development
├── Testnet.toml   # Pre-production testing
└── Mainnet.toml   # Production deployment
```

### Devnet Configuration

**File:** `settings/Devnet.toml`

```toml
[network]
name = "devnet"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "your devnet mnemonic here"
balance = 100000000000

[accounts.wallet_1]
mnemonic = "customer test mnemonic"
balance = 100000000000

[accounts.wallet_2]
mnemonic = "installer test mnemonic"
balance = 100000000000
```

### Testnet Configuration

**File:** `settings/Testnet.toml`

```toml
[network]
name = "testnet"
node_rpc_address = "https://api.testnet.hiro.so"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "your testnet mnemonic here"
```

### Mainnet Configuration

**File:** `settings/Mainnet.toml`

```toml
[network]
name = "mainnet"
node_rpc_address = "https://api.hiro.so"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "your mainnet mnemonic here"
```

## Pre-Deployment Checklist

### 1. Code Review

- [ ] All contracts reviewed and audited
- [ ] Test coverage at 100%
- [ ] Security audit completed
- [ ] Documentation up to date

### 2. Testing

```bash
# Run all tests
npm test

# Generate coverage report
npm run test:report

# Check for issues
clarinet check
```

### 3. Contract Validation

```bash
# Validate all contracts
clarinet check

# Expected output:
# ✓ roles.clar
# ✓ escrow.clar
# ✓ service-marketplace.clar
# ✓ ups-solar-App.clar
```

### 4. Cost Analysis

Review deployment costs:

```bash
npm run test:report
```

Check the cost analysis section for:
- Contract deployment costs
- Function execution costs
- Storage requirements

## Deployment Process

### Devnet Deployment

#### Step 1: Start Local Devnet

```bash
cd ups-solar-App
clarinet integrate
```

This starts a local Stacks blockchain with:
- Bitcoin regtest node
- Stacks node
- Stacks API
- Explorer UI

#### Step 2: Deploy Contracts

```bash
# Deploy all contracts
clarinet deploy --devnet

# Or use the deployment script
./scripts/deploy.sh devnet
```

#### Step 3: Verify Deployment

```bash
# Check contract deployment
clarinet console

# In console:
(contract-call? .roles get-contract-owner)
(contract-call? .ups-solar-App get-version)
```

#### Step 4: Initialize Contracts

```bash
# Add initial installer (example)
clarinet console

# In console:
(contract-call? .roles add-installer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Testnet Deployment

#### Step 1: Prepare Testnet Account

1. Create or import wallet in Stacks Wallet
2. Get testnet STX from faucet: https://explorer.hiro.so/sandbox/faucet
3. Verify balance: https://explorer.hiro.so/address/[YOUR-ADDRESS]?chain=testnet

#### Step 2: Configure Deployment

Update `settings/Testnet.toml` with your mnemonic:

```toml
[accounts.deployer]
mnemonic = "your testnet mnemonic phrase here"
```

#### Step 3: Deploy to Testnet

```bash
# Deploy all contracts
clarinet deploy --testnet

# Or use deployment script
./scripts/deploy.sh testnet
```

#### Step 4: Verify Deployment

Visit Testnet Explorer:
```
https://explorer.hiro.so/txid/[TRANSACTION-ID]?chain=testnet
```

Check contract status:
```bash
stacks-cli contract-call \
  --testnet \
  --contract-address [DEPLOYER-ADDRESS] \
  --contract-name ups-solar-App \
  --function-name get-version \
  --sender [DEPLOYER-ADDRESS]
```

#### Step 5: Initialize Contracts

```bash
# Add installers
stacks-cli contract-call \
  --testnet \
  --contract-address [DEPLOYER-ADDRESS] \
  --contract-name roles \
  --function-name add-installer \
  --sender [DEPLOYER-ADDRESS] \
  --arg principal:[INSTALLER-ADDRESS]
```

### Mainnet Deployment

⚠️ **WARNING**: Mainnet deployment is permanent and uses real STX. Ensure thorough testing on Testnet first.

#### Step 1: Final Preparations

- [ ] Complete security audit
- [ ] Test all functionality on Testnet
- [ ] Prepare deployment funds (estimate 5-10 STX)
- [ ] Backup all mnemonics securely
- [ ] Document deployment plan
- [ ] Prepare rollback strategy

#### Step 2: Configure Mainnet

Update `settings/Mainnet.toml`:

```toml
[accounts.deployer]
mnemonic = "your mainnet mnemonic phrase here"
```

⚠️ **SECURITY**: Never commit mainnet mnemonics to version control!

#### Step 3: Deploy to Mainnet

```bash
# Final check
clarinet check

# Deploy
clarinet deploy --mainnet

# Or use deployment script
./scripts/deploy.sh mainnet
```

#### Step 4: Verify Deployment

Visit Mainnet Explorer:
```
https://explorer.hiro.so/txid/[TRANSACTION-ID]?chain=mainnet
```

#### Step 5: Initialize Production

```bash
# Add production installers
stacks-cli contract-call \
  --mainnet \
  --contract-address [DEPLOYER-ADDRESS] \
  --contract-name roles \
  --function-name add-installer \
  --sender [DEPLOYER-ADDRESS] \
  --arg principal:[INSTALLER-ADDRESS]
```

## Deployment Scripts

### Build Script

**File:** `scripts/build.sh`

```bash
#!/bin/bash

echo "Building UPS Solar App..."

# Check contracts
echo "Validating contracts..."
clarinet check

if [ $? -eq 0 ]; then
    echo "✓ All contracts valid"
else
    echo "✗ Contract validation failed"
    exit 1
fi

# Run tests
echo "Running tests..."
npm test

if [ $? -eq 0 ]; then
    echo "✓ All tests passed"
else
    echo "✗ Tests failed"
    exit 1
fi

echo "Build complete!"
```

### Deploy Script

**File:** `scripts/deploy.sh`

```bash
#!/bin/bash

NETWORK=$1

if [ -z "$NETWORK" ]; then
    echo "Usage: ./deploy.sh [devnet|testnet|mainnet]"
    exit 1
fi

echo "Deploying to $NETWORK..."

# Validate before deployment
./scripts/build.sh

if [ $? -ne 0 ]; then
    echo "Build failed. Aborting deployment."
    exit 1
fi

# Deploy
clarinet deploy --$NETWORK

if [ $? -eq 0 ]; then
    echo "✓ Deployment successful"
else
    echo "✗ Deployment failed"
    exit 1
fi
```

### Test Script

**File:** `scripts/test.sh`

```bash
#!/bin/bash

echo "Running UPS Solar App tests..."

# Run tests with coverage
npm run test:report

if [ $? -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
```

## Post-Deployment

### 1. Verification

- [ ] Verify all contracts deployed successfully
- [ ] Check contract addresses
- [ ] Test basic functionality
- [ ] Verify access controls

### 2. Documentation

- [ ] Document contract addresses
- [ ] Update API documentation
- [ ] Create user guides
- [ ] Publish deployment announcement

### 3. Monitoring

Set up monitoring for:
- Contract interactions
- Transaction volume
- Error rates
- Gas usage
- Balance levels

### 4. Backup

- [ ] Backup deployment configuration
- [ ] Store contract addresses securely
- [ ] Document deployment process
- [ ] Archive deployment artifacts

## Troubleshooting

### Common Issues

#### Issue: Insufficient Funds

**Error:** "Insufficient balance for deployment"

**Solution:**
```bash
# Check balance
stacks-cli balance [ADDRESS] --testnet

# Get testnet STX from faucet
# Visit: https://explorer.hiro.so/sandbox/faucet
```

#### Issue: Contract Already Exists

**Error:** "Contract already deployed"

**Solution:**
- Use a different contract name
- Deploy from a different address
- Or update the existing contract (if supported)

#### Issue: Nonce Error

**Error:** "Invalid nonce"

**Solution:**
```bash
# Wait for pending transactions to confirm
# Check transaction status on explorer
# Retry deployment after confirmation
```

#### Issue: Network Timeout

**Error:** "Connection timeout"

**Solution:**
- Check network connectivity
- Verify RPC endpoint in configuration
- Try again after network stabilizes

### Getting Help

- **Clarinet Discord**: https://discord.gg/clarity
- **Stacks Forum**: https://forum.stacks.org
- **GitHub Issues**: [Your repository]/issues
- **Documentation**: https://docs.hiro.so

## Security Best Practices

### 1. Mnemonic Security

- Never commit mnemonics to version control
- Use environment variables for sensitive data
- Store mainnet mnemonics in secure vault
- Use hardware wallets for mainnet deployments

### 2. Access Control

- Verify contract owner is correct
- Test all authorization checks
- Document admin functions
- Implement multi-sig for critical operations

### 3. Upgrade Strategy

- Plan for contract upgrades
- Implement proxy patterns if needed
- Document upgrade procedures
- Test upgrade process on testnet

## Maintenance

### Regular Tasks

- Monitor contract activity
- Review transaction logs
- Update documentation
- Respond to user feedback
- Plan feature updates

### Emergency Procedures

1. **Critical Bug Discovered**
   - Assess impact
   - Notify users
   - Deploy fix to testnet
   - Test thoroughly
   - Deploy to mainnet

2. **Security Incident**
   - Pause affected functions (if possible)
   - Investigate issue
   - Communicate with users
   - Deploy security patch
   - Post-mortem analysis

## Conclusion

Following this deployment guide ensures a smooth and secure deployment process. Always test thoroughly on Devnet and Testnet before deploying to Mainnet.

For questions or issues, refer to the troubleshooting section or contact the development team.
