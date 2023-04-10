//Enter lottery(paying eth)
//pick random winner
//winner to be selected in every X minutes(Automated)
//Using chainlink oracles for randomness and automation(chainlink keepers)

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error Raffle__NotEnoughEth();
error Raffle__TransferFailed();

contract Raffle is VRFConsumerBaseV2 {
    // State Variables
    uint256 private immutable i_entranceFees;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    //Lottery Variables
    address private s_recentWinner;

    // Events
    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint16 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFees = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFees) {
            revert Raffle__NotEnoughEth();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    // This function will be run by chain link keeper inorder to automate the process
    function pickRandomWinner() external {
        // s1] request random winner
        // s2] once we get it do something with it
        // Requesting random number must be done in 2 transaction in order to ensure that no one can manipulate it

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gaslane: Maximum gas price willing to pay.
            i_subscriptionId, //for requesting any computation(random num in this case) from on chain to of chain i.e via oracle we need to pay for it and this is subsriptionId(paymentId) to that computation request
            REQUEST_CONFIRMATIONS, //How many confirmations the Chainlink node should wait before responding
            i_callbackGasLimit, //Maximum gas price willing to pay for fulfillRandomWords function
            NUM_WORDS //How many random values to request
        );

        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFees;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
