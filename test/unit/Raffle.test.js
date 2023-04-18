const { network, getNamedAccounts, deployments } = require("hardhat");
const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config");
const { assert } = require("chai");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Raffle Uint Tests", async function () {
      let raffle,
        vrfCoordinatorV2Mock,
        chainId = network.config.chainId;

      beforeEach(async function () {
        const { deployer } = await getNamedAccounts();
        await deployments.fixture(["all"]);
        raffle = await ethers.getContract("Raffle", deployer);
        vrfCoordinatorV2Mock = await ethers.getContract(
          "VRFCoordinatorV2Mock",
          deployer
        );
      });

      describe("constructor", async function () {
        it("initializes the raffle contract", async function () {
          const raffleState = await raffle.getRaffleState();
          const interval = await raffle.getInterval();
          assert.equal(raffleState.toString(), "0");
          console.log(chainId);
          console.log(networkConfig[chainId]["interval"]);
          assert.equal(
            interval.toString(),
            networkConfig[chainId]["keepersUpdateInterval"]
          );
        });
      });
    });
