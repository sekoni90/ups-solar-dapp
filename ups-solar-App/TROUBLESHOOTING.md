# Troubleshooting Guide

## Common Issues and Solutions

### ❌ "use of unresolved contract 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.roles'"

**What it means:** Your IDE's Clarity language server is analyzing contracts in isolation and can't find dependencies.

**Is this a real problem?** ❌ NO! This is a false positive from your IDE.

**Proof your contracts work:**
```bash
# Run these commands - they should all pass:
npm test           # ✅ All tests pass
clarinet check     # ✅ All contracts valid
```

**Solutions:**

#### Solution 1: Ignore the IDE Error (Recommended)
The error is cosmetic. Your contracts are valid and will deploy correctly. The IDE just can't analyze cross-contract calls in isolation.

#### Solution 2: Restart Your IDE
1. Close VS Code (or your editor)
2. Reopen the project folder
3. Wait 10-20 seconds for Clarity extension to reload

#### Solution 3: Reload Clarity Extension
In VS Code:
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Reload Window"
3. Press Enter

#### Solution 4: Clear Cache and Rebuild
```bash
# Windows PowerShell
Remove-Item -Recurse -Force .cache, .clarinet -ErrorAction SilentlyContinue
clarinet check

# Linux/Mac
rm -rf .cache .clarinet
clarinet check
```

#### Solution 5: Disable Strict Checking in IDE
If using the Clarity VS Code extension, you can disable strict checking:
1. Open VS Code settings
2. Search for "Clarity"
3. Disable strict mode or contract resolution

---

### ❌ "unsupported line-ending '\r', only '\n' is supported"

**What it means:** Your files have Windows line endings (CRLF) but Clarinet requires Unix line endings (LF).

**Solution:**
```bash
node fix-line-endings.js
```

Or manually in VS Code:
1. Open the file
2. Click "CRLF" in bottom-right status bar
3. Select "LF"
4. Save the file

---

### ❌ "error: use of unresolved variable 'block-height'"

**What it means:** You're using Clarity 2.0 syntax in Clarity 3.0.

**Solution:** Replace `block-height` with `stacks-block-height`

Already fixed in this project! ✅

---

### ❌ Tests Fail with "Cannot read properties of undefined"

**What it means:** Test is trying to access nested data incorrectly.

**Solution:** Use proper Clarity value matchers:
```typescript
// ❌ Wrong
const order = result.value.data;
expect(order.status).toBeUint(3);

// ✅ Correct
expect(result).toBeSome(
  Cl.tuple({
    status: Cl.uint(3),
    // ... other fields
  })
);
```

---

### ❌ "Contract already exists" during deployment

**What it means:** You're trying to deploy a contract that's already deployed.

**Solutions:**

1. **Use a different contract name** in Clarinet.toml
2. **Deploy from a different address**
3. **Clear the deployment** (devnet only):
   ```bash
   rm -rf .cache .clarinet
   clarinet integrate
   ```

---

### ❌ "Insufficient balance for deployment"

**What it means:** The deployer account doesn't have enough STX.

**Solutions:**

**For Devnet:**
- Already configured with 100,000 STX ✅

**For Testnet:**
1. Visit https://explorer.hiro.so/sandbox/faucet
2. Enter your address
3. Request testnet STX
4. Wait for confirmation

**For Mainnet:**
- Ensure you have sufficient STX in your wallet
- Deployment costs typically 5-10 STX

---

### ❌ Tests timeout or hang

**What it means:** A test is waiting indefinitely.

**Solutions:**

1. **Increase timeout** in vitest.config.js:
   ```javascript
   export default {
     test: {
       testTimeout: 30000 // 30 seconds
     }
   };
   ```

2. **Check for infinite loops** in contracts

3. **Restart the test**:
   ```bash
   npm test
   ```

---

### ❌ "Module not found" errors in tests

**What it means:** Dependencies aren't installed.

**Solution:**
```bash
npm install
```

---

### ⚠️ Warnings about "potentially unchecked data"

**What it means:** Clarinet is noting that user inputs are stored without additional validation.

**Is this a problem?** Usually NO. These are informational warnings.

**Current warnings in this project:**
1. `recipient` in escrow.clar - Acceptable, principal addresses are validated by Clarity
2. `description` in service-marketplace.clar - Acceptable, limited to 256 characters

**When to fix:** Only if you need additional validation logic.

---

## Verification Commands

Run these to verify everything works:

```bash
# 1. Check all contracts are valid
clarinet check
# Expected: ✔ 4 contracts checked

# 2. Run all tests
npm test
# Expected: Tests 5 passed (5)

# 3. Verify deployment plan
cat deployments/default.simnet-plan.yaml
# Should list all 4 contracts in order

# 4. Test in console (optional)
clarinet console
# Then try: (contract-call? .roles get-contract-owner)
```

---

## Getting Help

If you're still stuck:

1. **Check the documentation:**
   - [ARCHITECTURE.md](docs/ARCHITECTURE.md)
   - [API.md](docs/API.md)
   - [TESTING.md](docs/TESTING.md)
   - [DEPLOYMENT.md](docs/DEPLOYMENT.md)

2. **Verify your environment:**
   ```bash
   clarinet --version  # Should be 3.8+
   node --version      # Should be 18+
   npm --version       # Should be 9+
   ```

3. **Community resources:**
   - [Clarity Discord](https://discord.gg/clarity)
   - [Stacks Forum](https://forum.stacks.org)
   - [Clarinet Docs](https://docs.hiro.so/clarinet)

4. **Create an issue:**
   - Include error message
   - Include output of `clarinet check`
   - Include output of `npm test`
   - Include your environment info

---

## Quick Fixes Checklist

When something goes wrong, try these in order:

- [ ] Run `npm test` - Do tests pass?
- [ ] Run `clarinet check` - Do contracts validate?
- [ ] Clear cache: `rm -rf .cache .clarinet`
- [ ] Restart your IDE
- [ ] Check line endings: `node fix-line-endings.js`
- [ ] Reinstall dependencies: `npm install`
- [ ] Check Clarinet version: `clarinet --version`

If all of the above pass, your project is working correctly! The error is likely just an IDE display issue.

---

## Project Status Indicators

### ✅ Everything Working
```bash
$ npm test
Tests 5 passed (5)

$ clarinet check
✔ 4 contracts checked
```

### ⚠️ IDE Shows Errors But Project Works
- Tests pass ✅
- Clarinet check passes ✅
- IDE shows red squiggles ⚠️
- **Action:** Ignore IDE errors, restart IDE, or see solutions above

### ❌ Real Problem
- Tests fail ❌
- Clarinet check fails ❌
- **Action:** Check error messages and apply solutions above

---

**Remember:** If `npm test` and `clarinet check` both pass, your project is working correctly! IDE errors are often false positives.
