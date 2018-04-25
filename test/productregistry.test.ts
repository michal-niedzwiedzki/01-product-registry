import { assert } from 'chai';

import * as Web3 from 'web3';

import { ProductRegistry, ProjectArtifacts } from 'project';

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
  // console.log(accounts);

  const owner = accounts[9];
  const nonOwner = accounts[8];

  let registry: ProductRegistry;

  beforeEach(async () => {
    registry = await ProductRegistryContract.new({ from: owner });
  });

  describe('#ctor', () => {
    it('should create', async () => {
      assert.isOk(registry);
// FIXME     assert.equal(registry.owner, owner); 
    });

    it('should greet', async () => {
      assert.equal((await registry.greet()), "hi");
    });
  });

});
