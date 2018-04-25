import { assert } from 'chai';

import * as Web3 from 'web3';

import { ProductRegistry, ProjectArtifacts, ProductDeregistered } from 'project';

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

    it('should create', async () => {
      assert.isOk(registry);
      // FIXME     assert.equal(registry.owner, owner);
    });

  });

  describe('Registration', () => {

    it('should start with empty product set', async () => {
      const addresses = await registry.getProductAddresses();
      assert.isEmpty(addresses);
    });

    it('should revert registering product as non-owner', async () => {
      await assertReverts(async () => {
        await registry.registerProduct(product1, 100, { from: nonOwner });
      });
    });

    it('should register product as owner and emit', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await registry.registerProduct(product2, 200, { from: owner });
      const addresses = await registry.getProductAddresses();
      assert.equal(addresses.length, 2);
      assert.equal(addresses[0], product1);
      assert.equal(addresses[1], product2);
    });

    it('should revert on registering duplicate product', async () => {
      await registry.registerProduct(product1, 100);
      await assertReverts(async () => {
        await registry.registerProduct(product1, 200);
      });
    });

  });

  describe('Deregistration', () => {

    it('should revert deregistering product as non-owner', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await assertReverts(async () => {
        await registry.deregisterProduct(product1, { from: nonOwner });
      });
    });

    it('should deregister product as owner', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await registry.deregisterProduct(product1, { from: owner });
      assert.isEmpty(await registry.getProductAddresses());
    });

    it('should not emit deregistering product from empty set', async () => {
      const tx = await registry.deregisterProduct(product1, { from: owner });
      const log = findLastLog(tx, 'ProductDeregistered');
      assert.isOk(log);
      const event = log.args as ProductDeregistered;
      assert.equal(event.at, product1);
    });

    it('should not emit deregistering product never registered before', async () => {
      await registry.registerProduct(product1, 100, { from: owner });
      await registry.deregisterProduct(product2, { from: owner });
    });

    it('should not emit deregistering already deregistered product', async () => {
      await assertReverts(async () => {
        await registry.registerProduct(product1, 100, { from: owner });
        assert.equal((await registry.getProductAddresses()).length, 1);
        await registry.deregisterProduct(product1, { from: owner });
        assert.isEmpty(await registry.getProductAddresses());
        await registry.deregisterProduct(product1, { from: owner });
        // TODO add event checking
      });
    });

  });

});
