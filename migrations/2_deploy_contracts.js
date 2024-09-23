var LendingPool = artifacts.require("./LiquidityPool.sol");
module.exports = function (deployer) {
  // deployer.deploy(LendingPool, "Hi QuickNode!");
  deployer.deploy(LendingPool);
};
