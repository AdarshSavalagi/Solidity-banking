// migrations/2_deploy_complexbank.js
const ComplexBank = artifacts.require("Banking");

module.exports = function (deployer) {
  deployer.deploy(ComplexBank);
};
