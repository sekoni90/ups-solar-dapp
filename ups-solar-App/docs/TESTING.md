# Testing Guide

## Overview

This document provides comprehensive testing guidelines for the UPS Solar App smart contracts. The test suite uses Vitest and the Clarinet SDK to ensure contract reliability and security.

## Test Structure

```
tests/
├── roles_test.ts                 # Role management tests
├── escrow_test.ts                # Escrow functionality tests
├── service-marketplace_test.ts   # Marketplace tests
└── ups-solar-App.test.ts         # Integration tests
```

## Prerequisites

### Installation

```bash
cd ups-solar-App
npm install
```

### Required Dependencies

- `@hirosystems/clarinet-sdk`: ^3.6.0
- `vitest`: ^3.2.4
- `vitest-environment-clarinet`: ^2.3.0
- `@stacks/transactions`: ^7.2.0

## Running Tests

### Run All Tests

```bash
npm test
```

### Run Tests with Coverage

```bash
npm run test:report
```

### Watch Mode (Development)

```bash
npm run test:watch
```

### Run Specific Test File

```bash
npx vitest run tests/roles_test.ts
```

## Test Categories

### 1. Roles Contract Tests

**File:** `tests/roles_test.ts`

**Coverage:**
- ✅ Installer addition by contract owner
- ✅ Unauthorized installer addition prevention
- ✅ Duplicate installer prevention
- ✅ Installer removal
- ✅ Installer status verification
- ✅ Metadata tracking
- ✅ Total installer count

**Key Test Cases:**

```typescript
// Adding installer
it("should allow contract owner to add installer", () => {
  const { result } = simnet.callPublicFn(
    "roles",
    "add-installer",
    [Cl.principal(wallet1)],
    deployer
  );
  expect(result).toBeOk(Cl.bool(true));
});

// Authorization check
it("should prevent non-owner from adding installer", () => {
  const { result } = simnet.callPublicFn(
    "roles",
    "add-installer",
    [Cl.principal(wallet2)],
    wallet1
  );
  expect(result).toBeErr(Cl.uint(100)); // ERR-NOT-AUTHORIZED
});
```

### 2. Escrow Contract Tests

**File:** `tests/escrow_test.ts`

**Coverage:**
- ✅ Escrow funding with validation
- ✅ Zero amount rejection
- ✅ Duplicate escrow prevention
- ✅ Fund transfer verification
- ✅ Authorized release
- ✅ Unauthorized release prevention
- ✅ Double release prevention
- ✅ Refund functionality
- ✅ Balance tracking

**Key Test Cases:**

```typescript
// Funding escrow
it("should successfully fund escrow", () => {
  const { result } = simnet.callPublicFn(
    "escrow",
    "fund-escrow",
    [Cl.uint(1), Cl.uint(1000000), Cl.principal(installer)],
    customer
  );
  expect(result).toBeOk(Cl.bool(true));
});

// Release authorization
it("should allow installer to release escrow", () => {
  const { result } = simnet.callPublicFn(
    "escrow",
    "release-escrow",
    [Cl.uint(1)],
    installer
  );
  expect(result).toBeOk(Cl.bool(true));
});
```

### 3. Service Marketplace Tests

**File:** `tests/service-marketplace_test.ts`

**Coverage:**
- ✅ Order creation with validation
- ✅ Service type validation
- ✅ Amount validation
- ✅ Installer assignment
- ✅ Order lifecycle (Pending → Assigned → In Progress → Completed)
- ✅ Order cancellation
- ✅ Status transition validation
- ✅ Customer order tracking
- ✅ Installer order tracking
- ✅ Order counter management

**Key Test Cases:**

```typescript
// Order creation
it("should successfully create an order", () => {
  const { result } = simnet.callPublicFn(
    "service-marketplace",
    "create-order",
    [
      Cl.uint(1),
      Cl.uint(5000000),
      Cl.stringAscii("Install UPS system")
    ],
    customer
  );
  expect(result).toBeOk(Cl.uint(1));
});

// Status progression
it("should allow installer to start order", () => {
  const { result } = simnet.callPublicFn(
    "service-marketplace",
    "start-order",
    [Cl.uint(1)],
    installer
  );
  expect(result).toBeOk(Cl.bool(true));
});
```

### 4. Integration Tests

**File:** `tests/ups-solar-App.test.ts`

**Coverage:**
- ✅ Complete order workflow
- ✅ Cross-contract interactions
- ✅ State consistency
- ✅ Platform fee calculations
- ✅ Version information

**Key Test Case:**

```typescript
it("should complete full order lifecycle with escrow", () => {
  // 1. Add installer
  simnet.callPublicFn("roles", "add-installer", [Cl.principal(installer)], deployer);
  
  // 2. Create order
  simnet.callPublicFn("service-marketplace", "create-order", [...], customer);
  
  // 3. Fund escrow
  simnet.callPublicFn("escrow", "fund-escrow", [...], customer);
  
  // 4. Assign installer
  simnet.callPublicFn("service-marketplace", "assign-installer", [...], deployer);
  
  // 5. Start order
  simnet.callPublicFn("service-marketplace", "start-order", [...], installer);
  
  // 6. Complete order
  simnet.callPublicFn("service-marketplace", "complete-order", [...], installer);
  
  // 7. Release escrow
  simnet.callPublicFn("escrow", "release-escrow", [...], installer);
  
  // Verify final state
  // ...
});
```

## Test Patterns

### Setup Pattern

```typescript
describe("Contract Tests", () => {
  beforeEach(() => {
    simnet.setEpoch("3.0");
    // Setup common state
    simnet.callPublicFn("roles", "add-installer", [Cl.principal(installer)], deployer);
  });

  it("test case", () => {
    // Test implementation
  });
});
```

### Error Testing Pattern

```typescript
it("should reject invalid input", () => {
  const { result } = simnet.callPublicFn(
    "contract",
    "function",
    [Cl.uint(0)], // Invalid input
    caller
  );
  expect(result).toBeErr(Cl.uint(103)); // ERR-INVALID-AMOUNT
});
```

### State Verification Pattern

```typescript
it("should update state correctly", () => {
  // Perform action
  simnet.callPublicFn("contract", "action", [...], caller);
  
  // Verify state
  const { result } = simnet.callReadOnlyFn(
    "contract",
    "get-state",
    [],
    caller
  );
  expect(result).toBeSome(expectedValue);
});
```

### Balance Tracking Pattern

```typescript
it("should transfer funds correctly", () => {
  const initialBalance = simnet.getAssetsMap().get("STX")?.get(address) || 0;
  
  // Perform transfer
  simnet.callPublicFn("contract", "transfer", [...], caller);
  
  const finalBalance = simnet.getAssetsMap().get("STX")?.get(address) || 0;
  expect(finalBalance).toBeGreaterThan(initialBalance);
});
```

## Coverage Goals

### Current Coverage

- **Roles Contract**: 100% function coverage
- **Escrow Contract**: 100% function coverage
- **Service Marketplace**: 100% function coverage
- **Main Contract**: 100% function coverage

### Coverage Report

Generate detailed coverage report:

```bash
npm run test:report
```

This generates:
- Function coverage statistics
- Branch coverage analysis
- Cost analysis for contract calls
- Detailed test results

## Best Practices

### 1. Test Isolation

Each test should be independent and not rely on state from other tests.

```typescript
beforeEach(() => {
  // Reset state for each test
  simnet.setEpoch("3.0");
});
```

### 2. Descriptive Test Names

Use clear, descriptive test names that explain what is being tested.

```typescript
it("should prevent non-installer from releasing escrow", () => {
  // Test implementation
});
```

### 3. Comprehensive Error Testing

Test all error conditions and edge cases.

```typescript
it("should reject zero amount", () => {
  const { result } = simnet.callPublicFn(...);
  expect(result).toBeErr(Cl.uint(103));
});
```

### 4. State Verification

Always verify state changes after operations.

```typescript
// Perform action
simnet.callPublicFn("contract", "action", [...], caller);

// Verify state
const { result } = simnet.callReadOnlyFn("contract", "get-state", [], caller);
expect(result).toBe(expectedValue);
```

### 5. Authorization Testing

Test both authorized and unauthorized access for protected functions.

```typescript
it("should allow authorized user", () => {
  const { result } = simnet.callPublicFn(..., authorizedUser);
  expect(result).toBeOk(...);
});

it("should reject unauthorized user", () => {
  const { result } = simnet.callPublicFn(..., unauthorizedUser);
  expect(result).toBeErr(Cl.uint(100));
});
```

## Debugging Tests

### Enable Verbose Output

```bash
npx vitest run --reporter=verbose
```

### Run Single Test

```bash
npx vitest run -t "test name pattern"
```

### Debug Mode

```bash
npx vitest run --inspect-brk
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Test Smart Contracts

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd ups-solar-App && npm install
      - run: cd ups-solar-App && npm test
      - run: cd ups-solar-App && npm run test:report
```

## Common Issues and Solutions

### Issue: Tests Timeout

**Solution:** Increase timeout in `vitest.config.js`:

```javascript
export default {
  test: {
    testTimeout: 30000
  }
};
```

### Issue: Simnet Not Initialized

**Solution:** Ensure `simnet.setEpoch("3.0")` is called in `beforeEach`:

```typescript
beforeEach(() => {
  simnet.setEpoch("3.0");
});
```

### Issue: Principal Address Errors

**Solution:** Use proper principal format from `simnet.getAccounts()`:

```typescript
const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
```

## Performance Testing

### Cost Analysis

Monitor contract execution costs:

```bash
npm run test:report
```

Review the cost report to identify expensive operations.

### Optimization Tips

1. Minimize map lookups
2. Use efficient data structures
3. Batch operations when possible
4. Avoid unnecessary state changes

## Security Testing

### Security Checklist

- ✅ Authorization checks on all protected functions
- ✅ Input validation on all public functions
- ✅ Reentrancy protection
- ✅ Integer overflow/underflow prevention
- ✅ Access control verification
- ✅ State consistency checks

### Audit Preparation

Before security audit:

1. Achieve 100% test coverage
2. Document all assumptions
3. Test all edge cases
4. Verify error handling
5. Review access controls

## Next Steps

1. Run the complete test suite: `npm test`
2. Review coverage report: `npm run test:report`
3. Add custom test cases for your specific use cases
4. Set up CI/CD pipeline for automated testing
5. Schedule regular security audits

## Resources

- [Clarinet Documentation](https://docs.hiro.so/clarinet)
- [Vitest Documentation](https://vitest.dev/)
- [Clarity Language Reference](https://docs.stacks.co/clarity)
- [Stacks Blockchain Documentation](https://docs.stacks.co/)
