const fs = require('fs');
const path = require('path');

require('@nomiclabs/hardhat-truffle5');
require('@nomiclabs/hardhat-solhint');
require('solidity-coverage');
require('hardhat-gas-reporter');

let secret = {
  mnemonic: "test test test test test test test test test test test junk",
  infuraKey: "",
};

try {
  // Secret file format is:
  // { mnemonic: '', infuraKey, '', endpoints: { <networkname>: 'http://endpoint' } }
  const path = __dirname + "/" + ".secret.json";
  if (fs.existsSync(path)) {
    secret = JSON.parse(fs.readFileSync(path));
  }
} catch(err) {
  console.warn('No secret configuration found!');
}

const enableGasReport = !!process.env.ENABLE_GAS_REPORT;

module.exports = {
  solidity: {
    version: '0.8.1',
    settings: {
      optimizer: {
        enabled: enableGasReport,
        runs: 10000,
      },
    },
  },
  networks: {
    hardhat: {
      blockGasLimit: 10000000,
    },
    goerli: {
      url: 'https://goerli.infura.io/v3/' + secret.infuraKey,
      chainId: 5,
      gas: 'auto',
      accounts: {
        mnemonic: secret.mnemonic,
      }
    },
  },
  gasReporter: {
    enable: enableGasReport,
    currency: 'CHF',
    outputFile: process.env.CI ? 'gas-report.txt' : undefined,
  },
};
