import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;
const wallet3 = accounts.get("wallet_3")!;

describe("Roles Contract Tests", () => {
  beforeEach(() => {
    simnet.setEpoch("3.0");
  });

  describe("Installer Management", () => {
    it("should allow contract owner to add installer", () => {
      const { result } = simnet.callPublicFn(
        "roles",
        "add-installer",
        [Cl.principal(wallet1)],
        deployer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should prevent non-owner from adding installer", () => {
      const { result } = simnet.callPublicFn(
        "roles",
        "add-installer",
        [Cl.principal(wallet2)],
        wallet1
      );
      expect(result).toBeErr(Cl.uint(100)); // ERR-NOT-AUTHORIZED
    });

    it("should prevent adding duplicate installer", () => {
      simnet.callPublicFn("roles", "add-installer", [Cl.principal(wallet1)], deployer);
      
      const { result } = simnet.callPublicFn(
        "roles",
        "add-installer",
        [Cl.principal(wallet1)],
        deployer
      );
      expect(result).toBeErr(Cl.uint(102)); // ERR-ALREADY-EXISTS
    });

    it("should allow contract owner to remove installer", () => {
      simnet.callPublicFn("roles", "add-installer", [Cl.principal(wallet1)], deployer);
      
      const { result } = simnet.callPublicFn(
        "roles",
        "remove-installer",
        [Cl.principal(wallet1)],
        deployer
      );
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should prevent removing non-existent installer", () => {
      const { result } = simnet.callPublicFn(
        "roles",
        "remove-installer",
        [Cl.principal(wallet1)],
        deployer
      );
      expect(result).toBeErr(Cl.uint(101)); // ERR-NOT-FOUND
    });
  });

  describe("Read-Only Functions", () => {
    it("should correctly identify installer status", () => {
      simnet.callPublicFn("roles", "add-installer", [Cl.principal(wallet1)], deployer);
      
      const { result: isInstaller } = simnet.callReadOnlyFn(
        "roles",
        "is-installer",
        [Cl.principal(wallet1)],
        deployer
      );
      expect(isInstaller).toBeBool(true);

      const { result: notInstaller } = simnet.callReadOnlyFn(
        "roles",
        "is-installer",
        [Cl.principal(wallet2)],
        deployer
      );
      expect(notInstaller).toBeBool(false);
    });

    it("should return correct contract owner", () => {
      const { result } = simnet.callReadOnlyFn(
        "roles",
        "get-contract-owner",
        [],
        deployer
      );
      expect(result).toBePrincipal(deployer);
    });

    it("should track total installers correctly", () => {
      simnet.callPublicFn("roles", "add-installer", [Cl.principal(wallet1)], deployer);
      simnet.callPublicFn("roles", "add-installer", [Cl.principal(wallet2)], deployer);
      
      const { result } = simnet.callReadOnlyFn(
        "roles",
        "get-total-installers",
        [],
        deployer
      );
      expect(result).toBeUint(2);
    });

    it("should retrieve installer metadata", () => {
      simnet.callPublicFn("roles", "add-installer", [Cl.principal(wallet1)], deployer);
      
      const { result } = simnet.callReadOnlyFn(
        "roles",
        "get-installer-metadata",
        [Cl.principal(wallet1)],
        deployer
      );
      expect(result).toBeSome(
        Cl.tuple({
          "added-at": Cl.uint(simnet.blockHeight),
          "added-by": Cl.principal(deployer),
          "active": Cl.bool(true)
        })
      );
    });
  });
});
