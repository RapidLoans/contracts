var LiquidityPool = artifacts.require("./LiquidityPool.sol");
var FlashLoanCore = artifacts.require("./FlashLoanCore.sol");
var Subject = artifacts.require("./Subject.sol");

module.exports = function (deployer) {
  // deployer.deploy(LendingPool, "Hi QuickNode!");
  deployer.deploy(LiquidityPool);
  deployer.deploy(FlashLoanCore, LiquidityPool.address);
  deployer.deploy(Subject, FlashLoanCore.address);
};
