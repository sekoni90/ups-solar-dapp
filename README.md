# UPS Solar App

> Professional service marketplace platform for UPS, Solar, and Electrical installations built on Stacks blockchain

[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-blue)](https://clarity-lang.org/)
[![Clarinet](https://img.shields.io/badge/Clarinet-3.8-green)](https://github.com/hirosystems/clarinet)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

UPS Solar App is a comprehensive smart contract platform that facilitates secure transactions between customers and service providers. The platform features role-based access control, escrow payment protection, and complete order lifecycle management.

### Key Features

- **🔐 Role-Based Access Control**: Secure installer management and authorization
- **💰 Escrow System**: Protected payments with release and refund capabilities
- **📋 Order Management**: Complete lifecycle tracking from creation to completion
- **🔄 Integrated Workflows**: Streamlined processes combining multiple operations
- **📊 Comprehensive Tracking**: Customer and installer order history
- **✅ Full Test Coverage**: 100% tested with professional test suite

## Architecture

The platform consists of four interconnected smart contracts:

```
┌─────────────────────────────────────────┐
│       ups-solar-App.clar (Main)         │
│  - Orchestrates all contracts           │
│  - Integrated workflows                 │
│  - Platform fee management              │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼──────┐  ┌────▼─────────────────┐
│ roles.clar  │  │ service-marketplace  │
│ - Installer │  │ - Order creation     │
│   management│  │ - Status tracking    │
│ - Access    │  │ - Lifecycle mgmt     │
│   control   │  └──────────────────────┘
└──────┬──────┘
       │
┌──────▼──────┐
│ escrow.clar │
│ - Fund hold │
│ - Release   │
│ - Refunds   │
└─────────────┘
```

## Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) 3.8+
- [Node.js](https://nodejs.org/) 18+
- [Git](https://git-scm.com/)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ups-solar-dapp.git
cd ups-solar-dapp/ups-solar-App

# Install dependencies
npm install

# Verify installation
clarinet --version
npm --version
```

### Running Tests

```bash
# Run all tests
npm test

# Run with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

### Local Development

```bash
# Start local devnet
clarinet integrate

# In another terminal, deploy contracts
clarinet deploy --devnet

# Open Clarinet console
clarinet console
```

## Service Types

The platform supports three service categories:

| Service Type | Code | Description |
|-------------|------|-------------|
| UPS Installation | `1` | Uninterruptible Power Supply systems |
| Solar Installation | `2` | Solar panel and renewable energy systems |
| Electrical Service | `3` | General electrical services and repairs |

## Order Lifecycle

```
PENDING (0) → ASSIGNED (1) → IN-PROGRESS (2) → COMPLETED (3)
     ↓
CANCELLED (4)
```

## Usage Examples

### Create Order with Escrow

```clarity
;; Customer creates order with automatic escrow
(contract-call? .ups-solar-App create-order-with-escrow
  u1                                    ;; SERVICE-UPS
  u5000000                              ;; 5 STX
  "Install UPS system for office"      ;; Description
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; Installer
```

### Complete Order and Release Payment

```clarity
;; Installer completes work and receives payment
(contract-call? .ups-solar-App complete-order-and-release u1)
```

### Add Installer (Admin)

```clarity
;; Contract owner adds authorized installer
(contract-call? .roles add-installer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Architecture](ups-solar-App/docs/ARCHITECTURE.md)**: System design and contract relationships
- **[API Reference](ups-solar-App/docs/API.md)**: Complete function documentation
- **[Testing Guide](ups-solar-App/docs/TESTING.md)**: Test suite and best practices
- **[Deployment Guide](ups-solar-App/docs/DEPLOYMENT.md)**: Deployment procedures for all networks

## Project Structure

```
ups-solar-App/
├── contracts/
│   ├── ups-solar-App.clar           # Main orchestration contract
│   ├── roles.clar                   # Role management
│   ├── escrow.clar                  # Payment escrow
│   └── service-marketplace.clar     # Order management
├── tests/
│   ├── ups-solar-App.test.ts        # Integration tests
│   ├── roles_test.ts                # Role tests
│   ├── escrow_test.ts               # Escrow tests
│   └── service-marketplace_test.ts  # Marketplace tests
├── docs/
│   ├── ARCHITECTURE.md              # System architecture
│   ├── API.md                       # API documentation
│   ├── TESTING.md                   # Testing guide
│   └── DEPLOYMENT.md                # Deployment guide
├── scripts/
│   ├── build.sh                     # Build script
│   ├── deploy.sh                    # Deployment script
│   └── test.sh                      # Test script
├── settings/
│   ├── Devnet.toml                  # Devnet configuration
│   ├── Testnet.toml                 # Testnet configuration
│   └── Mainnet.toml                 # Mainnet configuration
├── Clarinet.toml                    # Project configuration
├── package.json                     # Node dependencies
└── README.md                        # This file
```

## Testing

The project includes a comprehensive test suite with 100% coverage:

- **Roles Tests**: 8 test cases covering installer management
- **Escrow Tests**: 12 test cases covering payment flows
- **Marketplace Tests**: 15 test cases covering order lifecycle
- **Integration Tests**: 5 test cases covering complete workflows

Run tests with:

```bash
npm test
```

## Deployment

### Devnet (Local)

```bash
./scripts/deploy.sh devnet
```

### Testnet

```bash
./scripts/deploy.sh testnet
```

### Mainnet

```bash
./scripts/deploy.sh mainnet
```

See [Deployment Guide](ups-solar-App/docs/DEPLOYMENT.md) for detailed instructions.

## Security

### Security Features

- Role-based access control
- Escrow payment protection
- Authorization checks on all sensitive operations
- Input validation on all public functions
- Comprehensive error handling

### Audit Status

- ✅ 100% test coverage
- ✅ All security checks implemented
- ⏳ External audit pending

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for all new features
- Maintain 100% test coverage
- Follow Clarity best practices
- Update documentation
- Add comments to complex logic

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | ERR-NOT-AUTHORIZED | Unauthorized access attempt |
| 101 | ERR-NOT-FOUND | Resource not found |
| 102 | ERR-ALREADY-EXISTS | Duplicate resource |
| 103 | ERR-INVALID-AMOUNT | Invalid payment amount |
| 104 | ERR-ALREADY-RELEASED | Escrow already released |
| 105 | ERR-INSUFFICIENT-FUNDS | Insufficient balance |
| 106 | ERR-INVALID-SERVICE-TYPE | Invalid service type |
| 107 | ERR-INVALID-STATUS | Invalid status transition |
| 108 | ERR-ORDER-ALREADY-COMPLETED | Cannot modify completed order |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [docs/](ups-solar-App/docs/)
- **Issues**: [GitHub Issues](https://github.com/yourusername/ups-solar-dapp/issues)
- **Discord**: [Clarity Discord](https://discord.gg/clarity)
- **Forum**: [Stacks Forum](https://forum.stacks.org)

## Acknowledgments

- Built with [Clarinet](https://github.com/hirosystems/clarinet)
- Powered by [Stacks Blockchain](https://www.stacks.co/)
- Tested with [Vitest](https://vitest.dev/)

## Roadmap

- [x] Core contract implementation
- [x] Comprehensive test suite
- [x] Professional documentation
- [ ] External security audit
- [ ] Testnet deployment
- [ ] Frontend application
- [ ] Rating and review system
- [ ] Dispute resolution mechanism
- [ ] Multi-signature support
- [ ] Mainnet deployment

---

**Built with ❤️ for the Stacks ecosystem**