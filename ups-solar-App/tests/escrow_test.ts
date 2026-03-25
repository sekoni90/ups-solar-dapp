import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const customer = accounts.get("wallet_1")!;
const installer = accounts.get("wallet_2")!;
const wallet3 = accounts.get("wallet_3")!;

describe("Escrow Contract Tests", () => {
  beforeEach(() => {
    simnet.setEpoch("3.0");
    // Setup: Add installer
    simnet.callPublicFn("roles", "add-installer", [Cl.principal(installer)], deployer);
  });

  describe("Fund Escrow", () => {
    it("should successfully fund escrow", () => {
      const orderId = 1;
      const amount = 1000000; // 1 STX

      const { result } = simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(orderId), Cl.uint(amount), Cl.principal(installer)],
        customer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should reject zero amount", () => {
      const { result } = simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(1), Cl.uint(0), Cl.principal(installer)],
        customer
      );
      expect(result).toBeErr(Cl.uint(103)); // ERR-INVALID-AMOUNT
    });

    it("should prevent duplicate escrow for same order", () => {
      const orderId = 1;
      const amount = 1000000;

      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(orderId), Cl.uint(amount), Cl.principal(installer)],
        customer
      );

      const { result } = simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(orderId), Cl.uint(amount), Cl.principal(installer)],
        customer
      );
      expect(result).toBeErr(Cl.uint(102)); // ERR-ALREADY-EXISTS
    });

    it("should transfer funds to contract", () => {
      const orderId = 1;
      const amount = 1000000;
      const initialBalance = simnet.getAssetsMap().get("STX")?.get(customer) || 0;

      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(orderId), Cl.uint(amount), Cl.principal(installer)],
        customer
      );

      const finalBalance = simnet.getAssetsMap().get("STX")?.get(customer) || 0;
      expect(finalBalance).toBeLessThan(initialBalance);
    });
  });

  describe("Release Escrow", () => {
    beforeEach(() => {
      // Fund escrow before each test
      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(1), Cl.uint(1000000), Cl.principal(installer)],
        customer
      );
    });

    it("should allow installer to release escrow", () => {
      const { result } = simnet.callPublicFn(
        "escrow",
        "release-escrow",
        [Cl.uint(1)],
        installer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should prevent non-installer from releasing escrow", () => {
      const { result } = simnet.callPublicFn(
        "escrow",
        "release-escrow",
        [Cl.uint(1)],
        wallet3
      );
      expect(result).toBeErr(Cl.uint(100)); // ERR-NOT-AUTHORIZED
    });

    it("should prevent double release", () => {
      simnet.callPublicFn("escrow", "release-escrow", [Cl.uint(1)], installer);

      const { result } = simnet.callPublicFn(
        "escrow",
        "release-escrow",
        [Cl.uint(1)],
        installer
      );
      expect(result).toBeErr(Cl.uint(104)); // ERR-ALREADY-RELEASED
    });

    it("should transfer funds to recipient", () => {
      const initialBalance = simnet.getAssetsMap().get("STX")?.get(installer) || 0;

      simnet.callPublicFn("escrow", "release-escrow", [Cl.uint(1)], installer);

      const finalBalance = simnet.getAssetsMap().get("STX")?.get(installer) || 0;
      expect(finalBalance).toBeGreaterThan(initialBalance);
    });
  });

  describe("Refund Escrow", () => {
    beforeEach(() => {
      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(1), Cl.uint(1000000), Cl.principal(installer)],
        customer
      );
    });

    it("should allow payer to refund escrow", () => {
      const { result } = simnet.callPublicFn(
        "escrow",
        "refund-escrow",
        [Cl.uint(1)],
        customer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should allow installer to refund escrow", () => {
      const { result } = simnet.callPublicFn(
        "escrow",
        "refund-escrow",
        [Cl.uint(1)],
        installer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should prevent unauthorized refund", () => {
      const { result } = simnet.callPublicFn(
        "escrow",
        "refund-escrow",
        [Cl.uint(1)],
        wallet3
      );
      expect(result).toBeErr(Cl.uint(100)); // ERR-NOT-AUTHORIZED
    });
  });

  describe("Read-Only Functions", () => {
    it("should retrieve escrow details", () => {
      const orderId = 1;
      const amount = 1000000;

      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(orderId), Cl.uint(amount), Cl.principal(installer)],
        customer
      );

      const { result } = simnet.callReadOnlyFn(
        "escrow",
        "get-escrow",
        [Cl.uint(orderId)],
        deployer
      );
      
      expect(result).toBeSome(
        Cl.tuple({
          payer: Cl.principal(customer),
          recipient: Cl.principal(installer),
          amount: Cl.uint(amount),
          released: Cl.bool(false),
          "created-at": Cl.uint(simnet.blockHeight),
          "released-at": Cl.none()
        })
      );
    });

    it("should check if escrow is active", () => {
      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(1), Cl.uint(1000000), Cl.principal(installer)],
        customer
      );

      const { result } = simnet.callReadOnlyFn(
        "escrow",
        "is-escrow-active",
        [Cl.uint(1)],
        deployer
      );
      expect(result).toBeBool(true);
    });

    it("should track total escrowed amount", () => {
      simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(1), Cl.uint(1000000), Cl.principal(installer)],
        customer
      );

      const { result } = simnet.callReadOnlyFn(
        "escrow",
        "get-total-escrowed",
        [],
        deployer
      );
      expect(result).toBeUint(1000000);
    });
  });
});
