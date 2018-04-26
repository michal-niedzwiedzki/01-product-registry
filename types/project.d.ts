declare module 'project' {
  import { BigNumber } from 'bignumber.js';
  import {
    AnyContract,
    Contract,
    ContractBase,
    TransactionOptions,
    TransactionResult,
    TruffleArtifacts
  } from 'truffle';
  import { AnyNumber } from 'web3';

  namespace project {
    interface Migrations extends ContractBase {
      setCompleted(
        completed: number,
        options?: TransactionOptions
      ): Promise<TransactionResult>;

      upgrade(
        address: Address,
        options?: TransactionOptions
      ): Promise<TransactionResult>;
    }

    interface ProductRegistered {
      owner: Address;
      price: number;
    }

    interface ProductDeregistered {
      owner: Address;
    }

    interface ProductRegistry extends ContractBase {
      owner: Address;
      registerProduct(
        owner: Address,
        price: number,
        options?: TransactionOptions
      ): Promise<TransactionResult>;
      deregisterProduct(
        owner: Address,
        options?: TransactionOptions
      ): Promise<TransactionResult>;
      deregisterAll(): Promise<TransactionResult>;
      getProductAddresses(): Promise<Address[]>;
      isProductRegistered(at: Address): Promise<boolean>;
      getProductPrice(at: Address): Promise<number>;
    }

    interface MigrationsContract extends Contract<Migrations> {
      'new'(options?: TransactionOptions): Promise<Migrations>;
    }

    interface ProductRegistryContract extends Contract<ProductRegistry> {
      'new'(options?: TransactionOptions): Promise<ProductRegistry>;
    }

    interface ProjectArtifacts extends TruffleArtifacts {
      require(name: string): AnyContract;
      require(name: './Migrations.sol'): MigrationsContract;
      require(name: './ProductRegistry.sol'): ProductRegistryContract;
    }
  }

  export = project;
}
