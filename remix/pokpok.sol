// SPDX-License-Identifier: Apache-2.0;
pragma solidity >=0.6;

import "./poker.onebiddinground.sol";

enum street {preflop, flop, turn, river}


contract table
{
    address public bank;
    uint8 maxPlayers;
    uint8 noOfCurrentPlayers;
    uint256 sb;
    uint256 bb;
    uint256 currentPot;
    uint256 minBuyIn;
    uint256 maxBuyIn;

    string tableName;

    struct Player
    {
        uint256 currentBalance;
        bool folded;
        bool active;
        uint8 currentPosition;
    }

    mapping (address => Player) players;

    // Events
    event PlayerJoined(address _account, uint256 _buyIn, uint8 _position);

    constructor(string memory _tableName, uint8 _maxPlayers, uint256 _bb, uint256 _minBuyIn, uint256 _maxBuyIn) public payable 
    {
        bank = address(this);
        maxPlayers = _maxPlayers;
        tableName = _tableName;
        sb = _bb / 2;
        bb = _bb;
        maxBuyIn = _maxBuyIn;
        minBuyIn = _minBuyIn;

        
    }

    function joinTable (uint256 _amount) external payable
    {
        Player memory newPlayer;
            
        require( _amount == msg. value, "amount doesnt match value");
            
        if(noOfCurrentPlayers < maxPlayers)
        {
            newPlayer.currentBalance = _amount;
        }

        players[msg.sender] = newPlayer;
        noOfCurrentPlayers++;
        emit PlayerJoined(msg.sender, players[msg.sender].currentBalance, noOfCurrentPlayers);
                
    }
    

        
}
