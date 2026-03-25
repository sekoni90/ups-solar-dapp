import { Simnet } from "@hirosystems/clarinet-sdk";
import { ClarityValue } from "@stacks/transactions";
import "vitest";

declare global {
  const simnet: Simnet;
}

declare module "vitest" {
  interface Assertion<T = any> {
    toBeOk(expected: ClarityValue): void;
    toBeErr(expected: ClarityValue): void;
    toBeSome(expected: ClarityValue): void;
    toBeNone(): void;
    toBeBool(expected: boolean): void;
    toBeUint(expected: number | bigint): void;
    toBeInt(expected: number | bigint): void;
    toBeAscii(expected: string): void;
    toBeUtf8(expected: string): void;
    toBePrincipal(expected: string): void;
    toBeBuff(expected: Uint8Array): void;
    toBeList(expected: ClarityValue[]): void;
    toBeTuple(expected: Record<string, ClarityValue>): void;
  }
  
  interface AsymmetricMatchersContaining {
    toBeOk(expected: ClarityValue): void;
    toBeErr(expected: ClarityValue): void;
    toBeSome(expected: ClarityValue): void;
    toBeNone(): void;
    toBeBool(expected: boolean): void;
    toBeUint(expected: number | bigint): void;
    toBeInt(expected: number | bigint): void;
    toBeAscii(expected: string): void;
    toBeUtf8(expected: string): void;
    toBePrincipal(expected: string): void;
    toBeBuff(expected: Uint8Array): void;
    toBeList(expected: ClarityValue[]): void;
    toBeTuple(expected: Record<string, ClarityValue>): void;
  }
}

export {};
