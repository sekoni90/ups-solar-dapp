# UPS Solar App - Architecture Documentation

## Overview

The UPS Solar App is a comprehensive service marketplace platform built on the Stacks blockchain using Clarity smart contracts. It facilitates secure transactions between customers and service providers for UPS, Solar, and Electrical installations.

## System Architecture

### Contract Structure

```
ups-solar-App/
├── ups-solar-App.clar       # Main orchestration contract
├── roles.clar               # Role-based access control
├── escrow.clar              # Payment escrow system
└── service-marketplace.clar # Order management
```

### Contract Relationships

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

## Core Components

### 1. Roles Contract (`roles.clar`)

**Purpose**: Manages installer authorization and access control

**Key Features**:
- Installer registration and removal
- Role verification
- Metadata tracking (added date, added by, status)
- Total installer count

**Data Structures**:
```clarity
(define-map installers principal bool)
(define-map installer-metadata principal {
  added-at: uint,
  added-by: principal,
  active: bool
})
```

### 2. Escrow Contract (`escrow.clar`)

**Purpose**: Secure payment holding and release mechanism

**Key Features**:
- Fund escrow creation
- Payment release to installers
- Refund capability
- Balance tracking

**Data Structures**:
```clarity
(define-map escrows uint {
  payer: principal,
  recipient: principal,
  amount: uint,
  released: bool,
  created-at: uint,
  released-at: (optional uint)
})
```

**Security Features**:
- Only authorized installers can release funds
- Prevents double-spending
- Tracks all transactions
- Refund protection

### 3. Service Marketplace Contract (`service-marketplace.clar`)

**Purpose**: Complete order lifecycle management

**Key Features**:
- Order creation with validation
- Installer assignment
- Status progression (Pending → Assigned → In Progress → Completed)
- Order cancellation
- Customer and installer order tracking

**Order Statuses**:
- `STATUS-PENDING (0)`: Order created, awaiting assignment
- `STATUS-ASSIGNED (1)`: Installer assigned
- `STATUS-IN-PROGRESS (2)`: Work started
- `STATUS-COMPLETED (3)`: Work finished
- `STATUS-CANCELLED (4)`: Order cancelled

**Service Types**:
- `SERVICE-UPS (1)`: UPS installation
- `SERVICE-SOLAR (2)`: Solar panel installation
- `SERVICE-ELECTRICAL (3)`: Electrical services

**Data Structures**:
```clarity
(define-map orders uint {
  customer: principal,
  installer: (optional principal),
  service-type: uint,
  amount: uint,
  status: uint,
  created-at: uint,
  assigned-at: (optional uint),
  completed-at: (optional uint),
  description: (string-ascii 256)
})
```

### 4. Main Contract (`ups-solar-App.clar`)

**Purpose**: Orchestration and integrated workflows

**Key Features**:
- Integrated order creation with escrow
- Combined order completion and payment release
- Platform fee management
- Comprehensive status queries

**Platform Economics**:
- Default platform fee: 5%
- Configurable by contract owner
- Fee calculation utilities

## Workflow Diagrams

### Complete Order Lifecycle

```
Customer                Marketplace           Roles           Escrow          Installer
   │                         │                  │               │                │
   │──create-order()────────>│                  │               │                │
   │<────order-id────────────│                  │               │                │
   │                         │                  │               │                │
   │──fund-escrow()──────────┼──────────────────┼──────────────>│                │
   │<────success─────────────┼──────────────────┼───────────────│                │
   │                         │                  │               │                │
   │                         │<─assign-installer┼──────────────>│                │
   │                         │                  │               │                │
   │                         │<─────────────────┼───────────────┼──start-order() │
   │                         │                  │               │                │
   │                         │<─────────────────┼───────────────┼──complete()────│
   │                         │                  │               │                │
   │                         │                  │               │<─release()─────│
   │                         │                  │               │────funds──────>│
```

### Installer Management

```
Contract Owner          Roles Contract
      │                      │
      │──add-installer()────>│
      │<────success──────────│
      │                      │
      │──remove-installer()─>│
      │<────success──────────│
```

## Security Considerations

### Access Control
- Contract owner has exclusive rights to add/remove installers
- Only authorized installers can release escrow
- Customers can only cancel their own orders
- Role verification on all sensitive operations

### Payment Security
- Funds locked in escrow until work completion
- Prevents unauthorized fund access
- Refund mechanism for disputes
- Double-spending prevention

### Data Integrity
- Immutable order history
- Timestamp tracking for all actions
- Status validation before state changes
- Input validation on all public functions

## Error Handling

### Standard Error Codes
```clarity
ERR-NOT-AUTHORIZED (100)      # Unauthorized access attempt
ERR-NOT-FOUND (101)           # Resource not found
ERR-ALREADY-EXISTS (102)      # Duplicate resource
ERR-INVALID-AMOUNT (103)      # Invalid payment amount
ERR-ALREADY-RELEASED (104)    # Escrow already released
ERR-INSUFFICIENT-FUNDS (105)  # Insufficient balance
ERR-INVALID-SERVICE-TYPE (106)# Invalid service type
ERR-INVALID-STATUS (107)      # Invalid status transition
ERR-ORDER-ALREADY-COMPLETED (108) # Cannot modify completed order
```

## Scalability Considerations

### Current Limitations
- Maximum 100 orders per customer (list limit)
- Maximum 100 orders per installer (list limit)
- Order description limited to 256 ASCII characters

### Future Enhancements
- Pagination for order lists
- Advanced search and filtering
- Rating and review system
- Dispute resolution mechanism
- Multi-signature escrow release
- Partial payment support

## Testing Strategy

### Unit Tests
- Individual contract function testing
- Edge case validation
- Error condition verification

### Integration Tests
- Complete workflow testing
- Cross-contract interaction
- State consistency verification

### Coverage Goals
- 100% function coverage
- All error paths tested
- All state transitions validated

## Deployment Considerations

### Prerequisites
- Clarinet 3.8+
- Node.js 18+
- Stacks wallet for deployment

### Network Deployment
1. **Devnet**: Local testing and development
2. **Testnet**: Pre-production validation
3. **Mainnet**: Production deployment

### Configuration
- Network-specific settings in `settings/` directory
- Contract dependencies properly configured
- Deployment scripts validated

## Monitoring and Maintenance

### Key Metrics
- Total orders created
- Total orders completed
- Total funds escrowed
- Total funds released
- Active installer count
- Platform fee collected

### Maintenance Tasks
- Regular security audits
- Performance monitoring
- User feedback integration
- Bug fixes and updates

## Version History

- **v1.0.0** (Current): Initial professional release
  - Complete RBAC system
  - Secure escrow mechanism
  - Full order lifecycle management
  - Comprehensive testing suite
