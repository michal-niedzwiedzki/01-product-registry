import { ProjectArtifacts } from 'project';
import { Deployer } from 'truffle';

declare const artifacts: ProjectArtifacts;

const RegistryConsumer = artifacts.require('./RegistryConsumer.sol');

async function deploy(deployer: Deployer) {
  await deployer.deploy(RegistryConsumer);
}

function migrate(deployer: Deployer) {
  deployer.then(() => deploy(deployer));
}

export = migrate;
