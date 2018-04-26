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
  const product1 = accounts[7];
  const product2 = accounts[6];

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
        await registry.registerProduct(product1, 100, { from: nonOwner });
      });
    });

    it('should register product as owner and emit', async () => {
      const tx1 = await registry.registerProduct(product1, 100, {
        from: owner
      });
      const tx2 = await registry.registerProduct(product2, 200, {
        from: owner
      });
      const log1 = findLastLog(tx1, 'ProductRegistered');
      const log2 = findLastLog(tx2, 'ProductRegistered');
      const addresses = await registry.getProductAddresses();
      assert.equal(addresses.length, 2);
      assert.equal(addresses[0], product1);
      assert.equal(addresses[1], product2);
      assert.isOk(log1);
      assert.isOk(log2);
      const event1 = log1.args as ProductRegistered;
      const event2 = log2.args as ProductRegistered;
      assert.equal(event1.at, product1);
      assert.equal(event1.price, 100);
      assert.equal(event2.at, product2);
      assert.equal(event2.price, 200);
    });

    it('should overwrite when registering existing product', async () => {
      const tx1 = await registry.registerProduct(product1, 100, {
        from: owner
      });
      const tx2 = await registry.registerProduct(product1, 101, {
        from: owner
      });
      const tx3 = await registry.registerProduct(product2, 200, {
        from: owner
      });
      const tx4 = await registry.registerProduct(product2, 201, {
        from: owner
      });
      const log2 = findLastLog(tx2, 'ProductRegistered');
      const log4 = findLastLog(tx4, 'ProductRegistered');
      const addresses = await registry.getProductAddresses();
      assert.equal(addresses.length, 2);
      assert.equal(addresses[0], product1);
      assert.equal(addresses[1], product2);
      assert.isOk(log2);
      assert.isOk(log4);
      const event2 = log2.args as ProductRegistered;
      const event4 = log4.args as ProductRegistered;
      assert.equal(event2.at, product1);
      assert.equal(event2.price, 101);
      assert.equal(event4.at, product2);
      assert.equal(event4.price, 201);
    });
  });

  describe('Deregistration', () => {
    it('should revert deregistering product as non-owner', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await assertReverts(async () => {
        await registry.deregisterProduct(product1, { from: nonOwner });
      });
    });

    it('should deregister product as owner and emit', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await registry.deregisterProduct(product1, { from: owner });
      assert.isEmpty(await registry.getProductAddresses());
    });

    it('should not emit deregistering product from empty set', async () => {
      const tx = await registry.deregisterProduct(product1, { from: owner });
      const log = findLastLog(tx, 'ProductDeregistered');
      assert.isUndefined(log);
    });

    it('should not emit deregistering product never registered', async () => {
      const tx1 = await registry.registerProduct(product1, 100, {
        from: owner
      });
      const tx2 = await registry.deregisterProduct(product2, { from: owner });
      const log2 = findLastLog(tx2, 'ProductDeregistered');
      assert.isUndefined(log2);
    });

    it('should not emit deregistering when already deregistered', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await registry.registerProduct(product2, 200, { from: owner });
      await registry.deregisterProduct(product1, { from: owner });
      await registry.deregisterProduct(product2, { from: owner });
      const tx1 = await registry.deregisterProduct(product1, { from: owner });
      const tx2 = await registry.deregisterProduct(product2, { from: owner });
      const log1 = findLastLog(tx1, 'ProductDeregistered');
      const log2 = findLastLog(tx2, 'ProductDeregistered');
      assert.isUndefined(log1);
      assert.isUndefined(log2);
    });
  });

  describe('Querying', () => {
    it('for product should return false on empty set', async () => {
      const isRegistered = await registry.isProductRegistered(product1);
      assert.isFalse(isRegistered);
    });

    it('for not registered product on non-empty set', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      const isRegistered = await registry.isProductRegistered(product2);
      assert.isFalse(isRegistered);
    });

    it('for registered product should return true', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      const isRegistered = await registry.isProductRegistered(product1);
      assert.isTrue(isRegistered);
    });

    it('for deregistered product should return false', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await registry.deregisterProduct(product1, { from: owner });
      const isRegistered = await registry.isProductRegistered(product1);
      assert.isFalse(isRegistered);
    });

    it('for price on registered product', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      const price = await registry.getProductPrice(product1);
      assert.equal(price, 100);
    });
  });
});
