import { ProjectArtifacts } from 'project';
import { Deployer } from 'truffle';

declare const artifacts: ProjectArtifacts;

const ProductRegistry = artifacts.require('./ProductRegistry.sol');

async function deploy(deployer: Deployer) {
  await deployer.deploy(ProductRegistry);
}

function migrate(deployer: Deployer) {
  deployer.then(() => deploy(deployer));
}

export = migrate;
