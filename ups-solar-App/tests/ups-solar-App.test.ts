import { describe, expect, it } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const customer = accounts.get("wallet_1")!;
const installer = accounts.get("wallet_2")!;

describe("UPS Solar App Integration Tests", () => {
  it("ensures simnet is well initialized", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  describe("Integrated Workflow", () => {
    it("should complete full order lifecycle with escrow", () => {
      simnet.setEpoch("3.0");
      
      // 1. Add installer
      const addInstaller = simnet.callPublicFn(
        "roles",
        "add-installer",
        [Cl.principal(installer)],
        deployer
      );
      expect(addInstaller.result).toBeOk(Cl.bool(true));

      // 2. Create order
      const createOrder = simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [
          Cl.uint(1), // UPS service
          Cl.uint(5000000), // 5 STX
          Cl.stringAscii("Complete UPS installation")
        ],
        customer
      );
      expect(createOrder.result).toBeOk(Cl.uint(1));

      // 3. Fund escrow
      const fundEscrow = simnet.callPublicFn(
        "escrow",
        "fund-escrow",
        [Cl.uint(1), Cl.uint(5000000), Cl.principal(installer)],
        customer
      );
      expect(fundEscrow.result).toBeOk(Cl.bool(true));

      // 4. Assign installer
      const assignInstaller = simnet.callPublicFn(
        "service-marketplace",
        "assign-installer",
        [Cl.uint(1), Cl.principal(installer)],
        deployer
      );
      expect(assignInstaller.result).toBeOk(Cl.bool(true));

      // 5. Start order
      const startOrder = simnet.callPublicFn(
        "service-marketplace",
        "start-order",
        [Cl.uint(1)],
        installer
      );
      expect(startOrder.result).toBeOk(Cl.bool(true));

      // 6. Complete order
      const completeOrder = simnet.callPublicFn(
        "service-marketplace",
        "complete-order",
        [Cl.uint(1)],
        installer
      );
      expect(completeOrder.result).toBeOk(Cl.bool(true));

      // 7. Release escrow
      const releaseEscrow = simnet.callPublicFn(
        "escrow",
        "release-escrow",
        [Cl.uint(1)],
        installer
      );
      expect(releaseEscrow.result).toBeOk(Cl.bool(true));

      // Verify final state
      const orderStatus = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-order",
        [Cl.uint(1)],
        deployer
      );
      const order = orderStatus.result.value as any;
      expect(order.data.status).toBeUint(3); // STATUS-COMPLETED

      const escrowStatus = simnet.callReadOnlyFn(
        "escrow",
        "get-escrow",
        [Cl.uint(1)],
        deployer
      );
      const escrow = escrowStatus.result.value as any;
      expect(escrow.data.released).toBeBool(true);
    });
  });

  describe("Main Contract Functions", () => {
    it("should get contract version", () => {
      const { result } = simnet.callReadOnlyFn(
        "ups-solar-App",
        "get-version",
        [],
        deployer
      );
      expect(result).toBeAscii("1.0.0");
    });

    it("should calculate platform fee correctly", () => {
      const { result } = simnet.callReadOnlyFn(
        "ups-solar-App",
        "calculate-platform-fee",
        [Cl.uint(1000000)], // 1 STX
        deployer
      );
      expect(result).toBeUint(50000); // 5% = 0.05 STX
    });

    it("should get platform fee percentage", () => {
      const { result } = simnet.callReadOnlyFn(
        "ups-solar-App",
        "get-platform-fee",
        [],
        deployer
      );
      expect(result).toBeUint(5); // 5%
    });
  });
});
