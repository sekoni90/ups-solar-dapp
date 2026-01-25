import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const customer = accounts.get("wallet_1")!;
const installer = accounts.get("wallet_2")!;
const wallet3 = accounts.get("wallet_3")!;

describe("Service Marketplace Contract Tests", () => {
  beforeEach(() => {
    simnet.setEpoch("3.0");
    // Setup: Add installer
    simnet.callPublicFn("roles", "add-installer", [Cl.principal(installer)], deployer);
  });

  describe("Order Creation", () => {
    it("should successfully create an order", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [
          Cl.uint(1), // SERVICE-UPS
          Cl.uint(5000000), // 5 STX
          Cl.stringAscii("Install UPS system for office building")
        ],
        customer
      );
      expect(result).toBeOk(Cl.uint(1));
    });

    it("should reject zero amount", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(0), Cl.stringAscii("Test order")],
        customer
      );
      expect(result).toBeErr(Cl.uint(103)); // ERR-INVALID-AMOUNT
    });

    it("should reject invalid service type", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(99), Cl.uint(1000000), Cl.stringAscii("Invalid service")],
        customer
      );
      expect(result).toBeErr(Cl.uint(106)); // ERR-INVALID-SERVICE-TYPE
    });

    it("should increment order counter", () => {
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(1000000), Cl.stringAscii("Order 1")],
        customer
      );

      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(2), Cl.uint(2000000), Cl.stringAscii("Order 2")],
        customer
      );
      expect(result).toBeOk(Cl.uint(2));
    });

    it("should track customer orders", () => {
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(1000000), Cl.stringAscii("Order 1")],
        customer
      );

      const { result } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-customer-orders",
        [Cl.principal(customer)],
        deployer
      );
      expect(result).toBeSome(Cl.list([Cl.uint(1)]));
    });
  });

  describe("Installer Assignment", () => {
    beforeEach(() => {
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(1000000), Cl.stringAscii("Test order")],
        customer
      );
    });

    it("should allow assigning authorized installer", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "assign-installer",
        [Cl.uint(1), Cl.principal(installer)],
        deployer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should reject unauthorized installer", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "assign-installer",
        [Cl.uint(1), Cl.principal(wallet3)],
        deployer
      );
      expect(result).toBeErr(Cl.uint(100)); // ERR-NOT-AUTHORIZED
    });

    it("should update order status to assigned", () => {
      simnet.callPublicFn(
        "service-marketplace",
        "assign-installer",
        [Cl.uint(1), Cl.principal(installer)],
        deployer
      );

      const { result } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-order",
        [Cl.uint(1)],
        deployer
      );
      
      // Extract the Some value and check the status field
      expect(result).toBeSome(
        expect.objectContaining({
          data: expect.objectContaining({
            status: Cl.uint(1) // STATUS-ASSIGNED
          })
        })
      );
    });

    it("should track installer orders", () => {
      simnet.callPublicFn(
        "service-marketplace",
        "assign-installer",
        [Cl.uint(1), Cl.principal(installer)],
        deployer
      );

      const { result } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-installer-orders",
        [Cl.principal(installer)],
        deployer
      );
      expect(result).toBeSome(Cl.list([Cl.uint(1)]));
    });
  });

  describe("Order Lifecycle", () => {
    beforeEach(() => {
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(1000000), Cl.stringAscii("Test order")],
        customer
      );
      simnet.callPublicFn(
        "service-marketplace",
        "assign-installer",
        [Cl.uint(1), Cl.principal(installer)],
        deployer
      );
    });

    it("should allow installer to start order", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "start-order",
        [Cl.uint(1)],
        installer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should prevent non-installer from starting order", () => {
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "start-order",
        [Cl.uint(1)],
        wallet3
      );
      expect(result).toBeErr(Cl.uint(100)); // ERR-NOT-AUTHORIZED
    });

    it("should allow installer to complete order", () => {
      simnet.callPublicFn("service-marketplace", "start-order", [Cl.uint(1)], installer);
      
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "complete-order",
        [Cl.uint(1)],
        installer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should update total completed orders", () => {
      simnet.callPublicFn("service-marketplace", "start-order", [Cl.uint(1)], installer);
      simnet.callPublicFn("service-marketplace", "complete-order", [Cl.uint(1)], installer);
      
      const { result } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-total-completed",
        [],
        deployer
      );
      expect(result).toBeUint(1);
    });

    it("should allow customer to cancel pending order", () => {
      // Create new order (pending status)
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(2), Cl.uint(2000000), Cl.stringAscii("Cancel test")],
        customer
      );

      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "cancel-order",
        [Cl.uint(2)],
        customer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should prevent canceling completed order", () => {
      simnet.callPublicFn("service-marketplace", "start-order", [Cl.uint(1)], installer);
      simnet.callPublicFn("service-marketplace", "complete-order", [Cl.uint(1)], installer);
      
      const { result } = simnet.callPublicFn(
        "service-marketplace",
        "cancel-order",
        [Cl.uint(1)],
        customer
      );
      expect(result).toBeErr(Cl.uint(108)); // ERR-ORDER-ALREADY-COMPLETED
    });
  });

  describe("Read-Only Functions", () => {
    it("should retrieve order details", () => {
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(1000000), Cl.stringAscii("Test order")],
        customer
      );

      const { result } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-order",
        [Cl.uint(1)],
        deployer
      );
      expect(result).toBeSome(
        Cl.tuple({
          customer: Cl.principal(customer),
          installer: Cl.none(),
          "service-type": Cl.uint(1),
          amount: Cl.uint(1000000),
          status: Cl.uint(0), // STATUS-PENDING
          "created-at": Cl.uint(simnet.blockHeight),
          "assigned-at": Cl.none(),
          "completed-at": Cl.none(),
          description: Cl.stringAscii("Test order")
        })
      );
    });

    it("should return service names correctly", () => {
      const { result: ups } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-service-name",
        [Cl.uint(1)],
        deployer
      );
      expect(ups).toBeAscii("UPS Installation");

      const { result: solar } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-service-name",
        [Cl.uint(2)],
        deployer
      );
      expect(solar).toBeAscii("Solar Installation");

      const { result: electrical } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-service-name",
        [Cl.uint(3)],
        deployer
      );
      expect(electrical).toBeAscii("Electrical Service");
    });

    it("should track total orders", () => {
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(1), Cl.uint(1000000), Cl.stringAscii("Order 1")],
        customer
      );
      simnet.callPublicFn(
        "service-marketplace",
        "create-order",
        [Cl.uint(2), Cl.uint(2000000), Cl.stringAscii("Order 2")],
        customer
      );

      const { result } = simnet.callReadOnlyFn(
        "service-marketplace",
        "get-total-orders",
        [],
        deployer
      );
      expect(result).toBeUint(2);
    });
  });
});
