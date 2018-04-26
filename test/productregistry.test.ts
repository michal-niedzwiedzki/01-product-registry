import { assert } from 'chai';

import * as Web3 from 'web3';

import {
  ProductDeregistered,
  ProductRegistered,
  ProductRegistry,
  ProjectArtifacts
} from 'project';

import { ContractContextDefinition } from 'truffle';
import {
  assertNumberEqual,
  assertReverts,
  findLastLog,
  ZERO_ADDRESS
} from './helpers';

declare const web3: Web3;
declare const artifacts: ProjectArtifacts;
declare const contract: ContractContextDefinition;

const ProductRegistryContract = artifacts.require('./ProductRegistry.sol');

contract('ProductRegistry', accounts => {
  const owner = accounts[9];
  const nonOwner = accounts[8];
  const product = accounts[7];

  let registry: ProductRegistry;

  beforeEach(async () => {
    registry = await ProductRegistryContract.new({ from: owner });
  });

  describe('Constructor', () => {
    it('should create with empty product set', async () => {
      assert.isOk(registry);
      const addresses = await registry.getProductAddresses();
      assert.isEmpty(addresses);
    });
  });

  describe('Registration', () => {
    it('should revert registering product as non-owner', async () => {
      await assertReverts(async () => {
        await registry.registerProduct(product, 100, { from: nonOwner });
      });
    });

    it('should register product as owner and emit', async () => {
      const tx = await registry.registerProduct(product, 100, { from: owner });
      const addresses = await registry.getProductAddresses();
      assert.equal(addresses.length, 1);
      assert.equal(addresses[0], product);
      
      const log = findLastLog(tx, 'ProductRegistered');
      const event = log.args as ProductRegistered;
      assert.isOk(log);
      assert.equal(event.owner, product);
      assert.equal(event.price, 100);

    });

    it('should revert if product already registered', async () => {
      await registry.registerProduct(product, 100, { from: owner });
      await assertReverts(async () => {
        await registry.registerProduct(product, 101, { from: owner });
      });
    });
  });

  describe('Deregistration', () => {
    it('should revert deregistering product as non-owner', async () => {
      await registry.registerProduct(product, 100, { from: owner });
      await assertReverts(async () => {
        await registry.deregisterProduct(product, { from: nonOwner });
      });
    });

    it('should deregister product as owner and emit', async () => {
      await registry.registerProduct(product, 100, { from: owner });
      await registry.deregisterProduct(product, { from: owner });
      assert.isEmpty(await registry.getProductAddresses());
    });

    it('should revert deregistering not registered product', async () => {
      await assertReverts(async () => {
        await registry.deregisterProduct(product, { from: owner });
      });
    });

    it('should deregister all products and emit', async () => {
      await registry.registerProduct(product, 100, { from: owner });
      const tx = await registry.deregisterProduct(product, { from: owner });
      assert.isEmpty(await registry.getProductAddresses());

      const log = findLastLog(tx, 'ProductDeregistered');
      const event = log.args as ProductDeregistered;
      assert.equal(event.owner, product);
    });

  });

  describe('Querying', () => {
    it('should return false when product not found', async () => {
      const isRegistered = await registry.isProductRegistered(product);
      assert.isFalse(isRegistered);
    });

    it('should return true when product found', async () => {
      await registry.registerProduct(product, 100, { from: owner });
      const isRegistered = await registry.isProductRegistered(product);
      assert.isTrue(isRegistered);
    });

    it('should return number for existing product', async () => {
      await registry.registerProduct(product, 100, { from: owner });
      const price = await registry.getProductPrice(product);
      assert.equal(price, 100);
    });

    it('should revert for non existing product', async () => {
      await assertReverts(async () => {
        await registry.getProductPrice(product);
      });
    });
  });
});
