// SPDX-License-Identifier: Apache-2.0;
pragma solidity >=0.6;
pragma experimental ABIEncoderV2;


  
import "./PlayerMapping.sol";
import "./poker.onebiddinground.sol";

/*
* My 6-player Texas Holdem for Ethereum
*/
contract table
{
    using PokerRound for PlayerMapping.Player[];
    using PlayerMapping for PlayerMapping.Players;

    
    PlayerMapping.Players public activePlayers;
    PlayerMapping.Players public waitingPlayers;
    
    PlayerMapping.packagedPlayer _addPlayer;

    bool continuePlaying;
    
    address public bank;
    uint8 maxPlayers;
    uint8 public noOfActivePlayers;
    uint8 public noOfWaitingPlayers;
    uint8 button;
    uint256 sb;
    uint256 bb;
    uint256 currentPot;
    uint256 minBuyIn;
    uint256 maxBuyIn;

    string tableName;

    

    uint8 constant MAXPLAYER = 10;

    uint8[13][4] cards;
    

    // Events
    event PlayerJoined(address _account, uint256 _buyIn, uint8 _position);

    constructor(string memory _tableName, uint8 _maxPlayers, uint256 _bb, uint256 _minBuyIn, uint256 _maxBuyIn)  payable 
    {
        bank = address(this);
        continuePlaying = true;
        maxPlayers = _maxPlayers;
        tableName = _tableName;
        sb = _bb / 2;
        bb = _bb;
        maxBuyIn = _maxBuyIn;
        minBuyIn = _minBuyIn;
    }

    function continousPlaying() public
    {
     PlayerMapping.Player[] memory tablePlayers;
     uint8 n;

    /*
     * heads-up needs separate logic
    */
     while((continuePlaying == true))
     {
       if (noOfActivePlayers < (MAXPLAYER - 1))
       {
        noOfActivePlayers = uint8(append(activePlayers, waitingPlayers));
        (n, tablePlayers) = serialize(activePlayers);
       }
       playPreFlop(tablePlayers, button, bb);
       playPostFlop(tablePlayers, button);
       /*
        * remove players from the array who have left the game
        * cash out each leaving player and rebuild activePlayers;
       */
       noOfActivePlayers = uint8(activePlayers.leaveTable());
     }
     // activePlayers.settle();
    }
    
    function playPreFlop(PlayerMapping.Player[] memory players, uint8 _button, uint256 _bb) public returns(bool)
    {
        PokerRound.BiddingState memory biddingState;
        uint256 amountWithdrawn;
        uint8 noOfPlayers;
        uint8 currentPlayerIndex;
   
        noOfPlayers = uint8(players.length);
        require(noOfPlayers > 2, "heads up is a on another table");
        biddingState.noOfCurrentPlayers =  noOfPlayers;
        amountWithdrawn = PokerRound.payIn(players, _button+1, _bb/2, biddingState);
        require(amountWithdrawn == _bb/2, "couldnt payIn sb");
        amountWithdrawn = PokerRound.payIn(players, _button+2 % noOfPlayers, _bb, biddingState);
        require(amountWithdrawn == _bb, "couldnt payIn bb");
        currentPlayerIndex = _button + 2;
        biddingState.streetState = PokerRound.PREFLOP;
        
        return(true);  
    }

    function playPostFlop(PlayerMapping.Player[] memory players, uint8 _button) public returns(bool)
    {  
     PokerRound.BiddingState memory biddingState;
     uint8 noOfPlayers;
     uint8 currentPlayerIndex;
     uint8 folded;
     uint8 r;

     noOfPlayers = uint8(players.length);
     biddingState.noOfCurrentPlayers =  noOfPlayers;
     currentPlayerIndex = _button;
     
     for ( r = 1; r < 4; r++) // 4 rounds: FLOP, TURN, RIVER. PRE-FLOP is handled separately as betting starts with UG
     {
         playOneRound(players, _button, currentPlayerIndex);
         if (folded > 0)
         {
             // noOfPlayers = players.prune();
         }

     } // while r < RIVER
     return (true);
    } // playGame

    function playOneRound(PlayerMapping.Player[] memory players, uint8 _button, uint8 currentPlayerIndex) 
        public returns(uint8)
    {
      PokerRound.action playerAction;
      uint8 noOfPlayers;
      uint8 folded;
      PokerRound.BiddingState memory biddingState;
      bool continueBetting = false;
  
      biddingState.firstBet = true; // first Bet in this betting round.
      biddingState.currentBet = 0;
      noOfPlayers = uint8(players.length);
      biddingState.noOfCurrentPlayers =  noOfPlayers;

        /*
        * we stop playing 
            - once the last player who has raised or bet calls or checks
            - the round has been traversed at least once
            - this is why we assign lastRaisedOrBet to button: once button is active we have done at least one full round
        */
      biddingState.lastRaisedOrBet = button;
      while(continueBetting == true) // bet within the current round until we reach final call
      {
        uint256 betSize;
        for(uint8 i = _button + 1; i < (noOfPlayers + _button + 1);i++) // go from sb to button 
        {
            currentPlayerIndex = i % noOfPlayers;
            if(! players[i].folded )
            {
             /*
             * in order to avoid money races we shift money from player to pot 
             * at the earliest possible, i.e. within getPlayerAction
             * all "accounting", i.e. lastBet, currentBet etc. is done here
             */
             (playerAction, betSize) = PokerRound.getPlayerAction(players, i, biddingState);
             if (playerAction == PokerRound.action.fold)
             {
                players[i].folded = true;
                folded++;
             }
             else
             {
                if(playerAction == PokerRound.action.check)
                {
                    continue;
                }
                else if (playerAction == PokerRound.action.call)
                {
                    players[i].lastBet = betSize;
                }
                else // bet or raise
                {
                    biddingState.lastRaisedOrBet = i;
                    biddingState.currentBet += betSize;
                }
             }
            }  // if player folded
            /*
            * this is the core condition to determine whether we can end the round and move to the next stage
            */
            int _nextActivePlayer = PlayerMapping.getNextActivePlayer(players, i);
            if( _nextActivePlayer < 0)
            {
                continueBetting = false;
            }
            else
            {
             if((biddingState.lastRaisedOrBet == _nextActivePlayer) && (playerAction != PokerRound.action.raise)
                && (playerAction != PokerRound.action.bet) )
             {
                continueBetting = false;
             }
            } 
        } // for i < noOfPlayers
      }
      return(folded);
    }

    function joinTable (uint256 _amount) external payable
    {
        PlayerMapping.Player memory newPlayer;
        PlayerMapping.Player memory p;
        bool a;

        require( _amount == msg.value, "amount doesnt match value");
            
        if((noOfActivePlayers + noOfWaitingPlayers) < maxPlayers)
        {
            newPlayer.currentBalance = _amount;
            newPlayer.account = address(msg.sender);
            newPlayer.active = true;
            _addPlayer._data[true] = newPlayer;    

        }
        if (PlayerMapping.insert(waitingPlayers, address(msg.sender), _addPlayer))
        {
            noOfWaitingPlayers++;
            (a,p) = waitingPlayers.get(msg.sender);
        }

        emit PlayerJoined(msg.sender, msg.value, noOfWaitingPlayers);
        noOfWaitingPlayers++;
           
    }    

    

    function append(PlayerMapping.Players storage _activePlayers, PlayerMapping.Players storage addPlayers) internal returns(uint)
    {
        uint length;
        uint newlength;
        uint8 i;
        address key;
        PlayerMapping.Player memory addPlayer;

        length = uint8(addPlayers.size);
        for (i=0; i < length; i++)
        {
            bool isRemoved;

            key = addPlayers.keys[i].key;
            addPlayer = addPlayers.playerByAddress[key].player;
            _addPlayer._data[true] = addPlayer;
            _activePlayers.insert(key, _addPlayer);
            (isRemoved, length)  = addPlayers.removePlayer(key);
        }
        require(newlength == 0, "error in adding waiting players to active roster");
        return(activePlayers.size);
    }

    function serialize(PlayerMapping.Players storage _Players) internal returns (uint8, PlayerMapping.Player[] memory)
    {
        uint8 arraySize;
        uint8 i;
        address key;
    

        arraySize = uint8(_Players.size);
        PlayerMapping.Player[] memory players = new PlayerMapping.Player[](arraySize);

        for (i=0; i < arraySize; i++)
        {
            key = _Players.keys[i].key;
            players[i] = _Players.playerByAddress[key].player;
        }

        return(arraySize, players);
    }
        
}