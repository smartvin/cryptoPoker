// SPDX-License-Identifier: Apache-2.0;
pragma solidity >=0.6;
pragma experimental ABIEncoderV2;

import "./PlayerMapping.sol";

library PokerRound 
{
 uint8 constant PREFLOP = 0;
 uint8 constant FLOP = 1;
 uint8 constant TURN = 2;
 uint8 constant RIVER = 4;


 enum action {check, fold, call, bet, raise}

 struct BiddingState
 {
    uint8 streetState; // 0 = preflop, 3 = river
    uint8 noOfCurrentPlayers;
    uint8 firstPlayer;
    uint8 currentPlayer;
    uint8 lastPlayer;
    uint8 button;
    bool firstBet;
    uint8 lastRaisedOrBet;
    uint256 currentBet;
    uint256 potSize;
 }

 
 function payIn(PlayerMapping.Player[] memory self, uint8 position, uint256 amount, BiddingState memory _biddingState) public pure returns(uint256)
 {
     require(self[position].currentBalance > amount, "not enough funds in wallet");
     self[position].currentBalance -= amount;
     _biddingState.potSize += amount;

     return(amount);
 }

 
 function getPlayerAction(PlayerMapping.Player[] memory players, uint8 _position, BiddingState memory state) pure public returns(action, uint256)
 {
    uint256 betSize;
     // player sees table
     // ask player for his action
    if(state.firstBet == true)
    {
        // betSize = askFirstBet(_position). 
        // We need either an actual w3js.msg or a valid signature within the channel here
        // we will have needed to shift the money to the pot and from the player
        if(betSize == 0)
        {
            return(action.check, 0);
        }
        else
        {
            return(action.bet, betSize);
        }
    }
    else // we need to fold, call or raise
    {
        // betSize = askFirstBet(_position)
        if(betSize == 0)
        {
            return(action.fold, 0);
        }
        else if((betSize + players[_position].lastBet) == state.currentBet) // player needs to add betSize to his lastBet to call
        {
            return(action.call, betSize);
        }
        else
        {
            require((betSize + players[_position].lastBet) > state.currentBet);
            return(action.raise, betSize);
        }
    }
    
 }

}

