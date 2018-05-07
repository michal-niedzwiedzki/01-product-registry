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
      getProductsCount(): Promise<number>;
      getNextAddress(from: Address): Promise<Address>;
      getFilteredCount(target: Address): Promise<number>;
    }

    interface RegistryConsumer extends ContractBase {
      getProducts(): Promise<Address[]>;
      filterProduct(price: number): Promise<boolean>;
    }

    interface MigrationsContract extends Contract<Migrations> {
      'new'(options?: TransactionOptions): Promise<Migrations>;
    }

    interface ProductRegistryContract extends Contract<ProductRegistry> {
      'new'(
        owner: Address,
        options?: TransactionOptions
      ): Promise<ProductRegistry>;
    }

    interface RegistryConsumerContract extends Contract<RegistryConsumer> {
      'new'(
        registryAddress: Address,
        options?: TransactionOptions
      ): Promise<RegistryConsumer>;
    }

    interface ProjectArtifacts extends TruffleArtifacts {
      require(name: string): AnyContract;
      require(name: './Migrations.sol'): MigrationsContract;
      require(name: './ProductRegistry.sol'): ProductRegistryContract;
      require(name: './RegistryConsumer.sol'): RegistryConsumerContract;
    }
  }

  export = project;
}
