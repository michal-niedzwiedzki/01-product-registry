import { assert } from 'chai';

import * as Web3 from 'web3';

import {
  ProductRegistry,
  RegistryConsumer,
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
const RegistryConsumerContract = artifacts.require('./RegistryConsumer.sol');

contract('RegistryConsumer', accounts => {
  const registryOwner = accounts[9];
  const consumerOwner = accounts[8];
  const product1 = accounts[7];
  const product2 = accounts[6];

  let registry: ProductRegistry;
  let consumer: RegistryConsumer;

  beforeEach(async () => {
    registry = await ProductRegistryContract.new(registryOwner, { from: registryOwner });
    consumer = await RegistryConsumerContract.new(registry.address, { from: consumerOwner });
  });

  describe('Constructor', () => {
    it('should create with reference to registry contract', async () => {
      assert.isOk(consumer);
//      assert.equal(consumer.registry.address, registry.address); // FIXME
    });
  });

  describe('Querying', () => {
    it('should return product addresses', async () => {
      await registry.registerProduct(product1, 100, { from: registryOwner });
      await registry.registerProduct(product2, 100, { from: registryOwner });
      const addresses = await consumer.getProducts();

      assert.equal(addresses.length, 2);
      assert.equal(addresses[0], product1);
      assert.equal(addresses[1], product2);
    });
  });
});
