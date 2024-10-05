// var LiquidityPool = artifacts.require("./LiquidityPool.sol");
// var RapidLoansCore = artifacts.require("./RapidLoansCore.sol");
// var Subject = artifacts.require("./Subject.sol");

// module.exports = function (deployer) {
//   deployer.deploy(LiquidityPool).then(function () {
//     return deployer
//       .deploy(RapidLoansCore, LiquidityPool.address)
//       .then(function () {
//         return deployer.deploy(Subject, RapidLoansCore.address);
//       });
//   });
// };
var LiquidityPool = artifacts.require("LiquidityPool");
var RapidLoansCore = artifacts.require("RapidLoansCore");
var Subject = artifacts.require("Subject");

module.exports = async function (deployer) {
  try {
    // Deploy LiquidityPool contract
    await deployer.deploy(LiquidityPool);
    const liquidityPoolInstance = await LiquidityPool.deployed();

    // Deploy RapidLoansCore contract, passing LiquidityPool address
    await deployer.deploy(RapidLoansCore, liquidityPoolInstance.address);
    const rapidLoansCoreInstance = await RapidLoansCore.deployed();

    // Deploy Subject contract, passing RapidLoansCore address
    await deployer.deploy(Subject, rapidLoansCoreInstance.address);
  } catch (error) {
    console.error("Error deploying contracts:", error);
  }
};
