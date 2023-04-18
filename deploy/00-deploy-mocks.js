const { network, ethers } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

//Constructor parameters

//(link per gas)Calculated based on gas price of the chain
//Chainlink nodes pay the gas fees to give us randomness and do external execution
//So the the price of request(base_fee) changes based on gas fees
const GAS_PRICE_LINK = 1e9;
const BASE_FEE = ethers.utils.parseEther("0.25"); //0.25 is premium i.e it is chainlink oracle gas

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  if (developmentChains.includes(network.name)) {
    log("Local network is detected now deploying mocks...");
    await deploy("VRFCoordinatorV2Mock", {
      from: deployer,
      log: true,
      args: [BASE_FEE, GAS_PRICE_LINK],
    });
    log("Mocks deployed");
    log("----------------------------------------------------");
  }
};

module.exports.tags = ["all", "mocks"];
