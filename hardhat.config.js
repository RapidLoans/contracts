require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: {
    version: "0.8.20",  // Change to match your contract
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
