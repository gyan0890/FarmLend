var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var FarmLend = artifacts.require("./FarmLend.sol");
var LockLoan = artifacts.require("./LockLoan.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(FarmLend);
  deployer.deploy(LockLoan);
};
