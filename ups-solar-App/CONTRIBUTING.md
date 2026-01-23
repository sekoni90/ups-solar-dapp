# Contributing to UPS Solar App

Thank you for your interest in contributing to the UPS Solar App! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what's best for the project
- Show empathy towards other contributors

## Getting Started

### Prerequisites

- Clarinet 3.8+
- Node.js 18+
- Git
- Basic understanding of Clarity smart contracts
- Familiarity with Stacks blockchain

### Setup Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/ups-solar-dapp.git
cd ups-solar-dapp/ups-solar-App

# Install dependencies
npm install

# Verify setup
clarinet check
npm test
```

## Development Process

### 1. Find or Create an Issue

- Check existing issues for tasks
- Create a new issue for bugs or features
- Discuss major changes before implementation

### 2. Create a Branch

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Or bug fix branch
git checkout -b fix/bug-description
```

### 3. Make Changes

- Write clean, documented code
- Follow coding standards
- Add tests for new functionality
- Update documentation

### 4. Test Your Changes

```bash
# Run all tests
npm test

# Check contract validity
clarinet check

# Generate coverage report
npm run test:report
```

### 5. Commit Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add new feature description"
```

#### Commit Message Format

Follow conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

**Examples:**
```
feat(escrow): add refund functionality
fix(roles): correct installer removal logic
docs(api): update function documentation
test(marketplace): add order cancellation tests
```

## Coding Standards

### Clarity Contracts

#### Naming Conventions

```clarity
;; Constants: UPPERCASE with hyphens
(define-constant ERR-NOT-AUTHORIZED (err u100))

;; Functions: lowercase with hyphens
(define-public (create-order ...)
(define-read-only (get-order ...)

;; Variables: lowercase with hyphens
(define-data-var order-counter uint u0)

;; Maps: lowercase with hyphens
(define-map orders uint {...})
```

#### Documentation

```clarity
;; @desc Brief function description
;; @param param-name: Parameter description
;; @returns Return value description
(define-public (function-name (param-name type))
  ;; Implementation
)
```

#### Code Structure

```clarity
;; =========================================================
;; CONTRACT NAME
;; Brief Description
;; =========================================================

;; -------------------------
;; Constants
;; -------------------------

;; -------------------------
;; Data Maps
;; -------------------------

;; -------------------------
;; Data Variables
;; -------------------------

;; -------------------------
;; Public Functions
;; -------------------------

;; -------------------------
;; Read-Only Functions
;; -------------------------
```

### TypeScript Tests

#### Naming Conventions

```typescript
// Test suites: descriptive names
describe("Escrow Contract Tests", () => {
  
  // Test cases: should statements
  it("should successfully fund escrow", () => {
    // Test implementation
  });
});
```

#### Test Structure

```typescript
describe("Feature Tests", () => {
  beforeEach(() => {
    // Setup
  });

  describe("Specific Functionality", () => {
    it("should handle normal case", () => {
      // Test
    });

    it("should handle error case", () => {
      // Test
    });
  });
});
```

### Best Practices

#### Security

- Always validate inputs
- Check authorization before sensitive operations
- Prevent reentrancy attacks
- Avoid integer overflow/underflow
- Use assertions for critical checks

#### Performance

- Minimize map lookups
- Use efficient data structures
- Avoid unnecessary state changes
- Batch operations when possible

#### Readability

- Write self-documenting code
- Add comments for complex logic
- Use descriptive variable names
- Keep functions focused and small

## Testing Guidelines

### Test Coverage Requirements

- **Minimum**: 90% coverage
- **Target**: 100% coverage
- All public functions must be tested
- All error paths must be tested
- All edge cases must be covered

### Writing Tests

```typescript
describe("Feature Tests", () => {
  beforeEach(() => {
    simnet.setEpoch("3.0");
    // Setup common state
  });

  it("should test normal operation", () => {
    // Arrange
    const input = Cl.uint(1000000);
    
    // Act
    const { result } = simnet.callPublicFn(
      "contract",
      "function",
      [input],
      caller
    );
    
    // Assert
    expect(result).toBeOk(Cl.bool(true));
  });

  it("should reject invalid input", () => {
    // Test error case
    const { result } = simnet.callPublicFn(
      "contract",
      "function",
      [Cl.uint(0)],
      caller
    );
    expect(result).toBeErr(Cl.uint(103));
  });
});
```

### Test Categories

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test contract interactions
3. **Edge Cases**: Test boundary conditions
4. **Error Cases**: Test error handling
5. **Security Tests**: Test authorization and validation

## Submitting Changes

### Pull Request Process

1. **Update Documentation**
   - Update README if needed
   - Update API docs for new functions
   - Add changelog entry

2. **Ensure Tests Pass**
   ```bash
   npm test
   clarinet check
   ```

3. **Push Changes**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request**
   - Use descriptive title
   - Reference related issues
   - Describe changes in detail
   - Add screenshots if applicable

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] All tests pass
- [ ] New tests added
- [ ] Coverage maintained/improved

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
```

## Review Process

### What Reviewers Look For

1. **Code Quality**
   - Follows coding standards
   - Well-documented
   - Clean and readable

2. **Functionality**
   - Solves the problem
   - No breaking changes
   - Handles edge cases

3. **Testing**
   - Adequate test coverage
   - Tests are meaningful
   - All tests pass

4. **Documentation**
   - Updated as needed
   - Clear and accurate
   - Examples provided

### Addressing Feedback

- Respond to all comments
- Make requested changes
- Ask questions if unclear
- Be open to suggestions

### Approval Process

- At least one approval required
- All comments addressed
- CI/CD checks pass
- No merge conflicts

## Additional Resources

### Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Testing Guide](docs/TESTING.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

### External Resources

- [Clarity Language Reference](https://docs.stacks.co/clarity)
- [Clarinet Documentation](https://docs.hiro.so/clarinet)
- [Stacks Blockchain Docs](https://docs.stacks.co/)

### Community

- [Stacks Discord](https://discord.gg/clarity)
- [Stacks Forum](https://forum.stacks.org)
- [GitHub Discussions](https://github.com/yourusername/ups-solar-dapp/discussions)

## Questions?

If you have questions:

1. Check existing documentation
2. Search closed issues
3. Ask in GitHub Discussions
4. Join our Discord community

Thank you for contributing to UPS Solar App! 🚀
