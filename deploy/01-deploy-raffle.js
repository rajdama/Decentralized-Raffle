const { network, ethers } = require("hardhat");
const {
  developmentChains,
  networkConfig,
} = require("../helper-hardhat-config");

const FUND_AMOUNT = ethers.utils.parseEther("1"); // 1 Ether, or 1e18 (10^18) Wei

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  let vrfCoordinatorV2Address, subscriptionId;

  if (developmentChains.includes(network.name)) {
    const vrfCoordinatorV2Mock = await ethers.getContract(
      "VRFCoordinatorV2Mock"
    );
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
    const transactionResponse = await vrfCoordinatorV2Mock.createSubscription();
    const transactionReceipt = await transactionResponse.wait();
    subscriptionId = transactionReceipt.events[0].args.subId;
    await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT);
  } else {
    vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"];
    subscriptionId = networkConfig[chainId]["subscriptionId"];
  }

  const arguments = [
    vrfCoordinatorV2Address,
    subscriptionId,
    networkConfig[chainId]["gasLane"],
    networkConfig[chainId]["raffleEntranceFee"],
    networkConfig[chainId]["keepersUpdateInterval"],
    networkConfig[chainId]["callbackGasLimit"],
  ];

  const raffle = await deploy("Raffle", {
    from: deployer,
    args: arguments,
    log: true,
    waitConfiramtions: network.config.blockConfirmations || 1,
  });

  log("Contract deployed");
  log("----------------------------------------------------");
};

module.exports.tags = ["all", "raffle"];
