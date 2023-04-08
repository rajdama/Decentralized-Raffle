//Enter lottery(paying eth)
//pick random winner
//winner to be selected in every X minutes(Automated)
//Using chainlink oracles for randomness and automation(chainlink keepers)

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

error Raffle__NotEnoughEth();

contract Raffle {
    // State Variables
    uint256 private immutable i_entranceFees;
    address payable[] private s_players;

    // Events
    event RaffleEnter(address indexed player);

    constructor(uint256 entranceFee) {
        i_entranceFees = entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFees) {
            revert Raffle__NotEnoughEth();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFees;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
