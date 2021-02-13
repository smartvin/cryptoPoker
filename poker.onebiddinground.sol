// SPDX-License-Identifier: Apache-2.0;
pragma solidity >=0.6;
pragma experimental ABIEncoderV2;

library PokerRound 
{

enum street {preflop, flop, turn, river}    
enum action {check, fold, bet, raise}


struct Player
    {
        uint256 currentBalance;
        bool folded;
        bool active;
        uint8 currentPosition;

    }


 struct BiddingState
 {
    street streetState;
    uint8 noOfCurrentPlayers;
    uint8 firstPlayer;
    uint8 currentPlayer;
    uint8 lastPlayer;
    uint8 button;
    bool firstBet;
    uint256 currentBet;
    uint256 potSize;

 }

 function getPlayerAction(uint8 _position, BiddingState memory state) internal returns(action)
 {
    uint256 betSize;
     // player sees table
     // ask player for his action
    if(state.firstBet == true)
    {
        // betSize = askFirstBet(_position)
        if(betSize == 0)
        {
            return(action.check);
        }
        else
        {
            state.currentBet += betSize;
            return(action.bet);
        }

    }
    else // we need to fold or raise
    {
        // betSize = askFirstBet(_position)
        if(betSize == 0)
        {
            return(action.fold);
        }
        else
        {
            state.currentBet += betSize;
            return(action.raise);
        }
    }
 }
 function nextCard(BiddingState memory state) internal returns(bool)
 {
     uint8 sb = state.button + 1;
     uint8 i;
     uint8 currentPosition;
     action playerAction;
     bool roundNotClosed;
     bool gameOver;

     currentPosition = state.currentPlayer;

      while(roundNotClosed)
      {


         i++;
      }
      return(gameOver);
 }     

 function playRound(Player[] calldata players) public returns(bool)
 {
     uint noOfPlayers = players.length;
     uint8 i;

    for (i=0; i < noOfPlayers; i++)
    {

    }
     return (true);
 }
}

