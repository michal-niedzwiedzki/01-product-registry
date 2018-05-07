import { ProjectArtifacts } from 'project';
import { Deployer } from 'truffle';

declare const artifacts: ProjectArtifacts;

const ProductRegistry = artifacts.require('./ProductRegistry.sol');
const RegistryConsumer = artifacts.require('./RegistryConsumer.sol');

async function deploy(deployer: Deployer) {
  const registry = await ProductRegistry.deployed();
  await deployer.deploy(RegistryConsumer, registry.address);
}

function migrate(deployer: Deployer) {
  deployer.then(() => deploy(deployer));
}

export = migrate;
