// SPDX-License-Identifier: Apache-2.0;
pragma solidity >=0.6;


import "./poker.onebiddinground.sol";


contract table
{
    address public bank;
    uint8 maxPlayers;
    uint8 noOfCurrentPlayers;
    uint8 button;
    uint256 sb;
    uint256 bb;
    uint256 currentPot;
    uint256 minBuyIn;
    uint256 maxBuyIn;

    string tableName;

    mapping (address => PokerRound.Player) waitingPlayers;
    uint8 constant MAXPLAYER = 10;

    uint8[13][4] cards;

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
        PokerRound.Player memory newPlayer;
            
        require( _amount == msg. value, "amount doesnt match value");
            
        if(noOfCurrentPlayers < maxPlayers)
        {
            newPlayer.currentBalance = _amount;
        }

        waitingPlayers[msg.sender] = newPlayer;
        noOfCurrentPlayers++;
        emit PlayerJoined(msg.sender, waitingPlayers[msg.sender].currentBalance, noOfCurrentPlayers);

        if(noOfCurrentPlayers > 1 && noOfCurrentPlayers <= maxPlayers)
        {
            // join list of players for next round
        }
           
    }
    
    function playGame() public
    {
        // while players at table > 2 < MAX
        // check if new player waiting
        // add new player and remove from waiting queue
        // delete waitingPlayers[newPlayer];
        //
        // currentPlayers[] players
        // playRound(players)
        // end while
    }


        
}