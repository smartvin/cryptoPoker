// SPDX-License-Identifier: Apache-2.0;
pragma solidity >=0.6;
pragma experimental ABIEncoderV2;

  


library PlayerMapping
{

 struct Player
 {
    address account;
    uint256 currentBalance;
    bool folded;
    bool active;
    uint8 currentPosition;
    uint256 lastBet;
 }
 struct indexedPlayer { uint keyIndex; Player player; }
 struct keyFlag {address key; bool deleted;}

 struct Players
 {
    mapping (address => indexedPlayer) playerByAddress;
    keyFlag[] keys;
    uint size;
 }
    
struct packagedPlayer
{
    mapping (bool => Player) _data;
}
struct arrayOfPlayers
{
    Player[] players;
}


    function leaveTable(PlayerMapping.Players storage _activePlayers) internal returns(uint)
    {
        uint length;
        uint newlength;
        uint i;
        address key;

        length = _activePlayers.size;
        for (i=0; i < length; i++)
        {
            bool isRemoved; 

            key = _activePlayers.keys[i].key;
            if ( _activePlayers.playerByAddress[key].player.active == false)
            {
                // TODO PlayerMapping.cashOut(_activePlayers, key);
                require(_activePlayers.playerByAddress[key].player.currentBalance == 0, "couldnt cash out player");
                (isRemoved, newlength) = removePlayer(_activePlayers, key);
            }
        }
        return(_activePlayers.size);
    }
    
    function insert(Players storage self, address key, packagedPlayer storage pPlayer) public returns (bool replaced) 
    {
        Player memory player;
        player = pPlayer._data[true];
        uint keyIndex = self.playerByAddress[key].keyIndex;
        self.playerByAddress[key].player = player;
        if (keyIndex > 0)
            return true;
        else {
            keyIndex = self.keys.length;
            self.keys.push();
            self.playerByAddress[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }

    function removePlayer(Players storage self, address key) internal returns (bool, uint) 
    {
        uint keyIndex = self.playerByAddress[key].keyIndex;
        if (keyIndex == 0)
            return (false, self.size);
        delete self.playerByAddress[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size --;
        return(true, self.size);
    }


    function get(Players storage self, address key) internal view returns (bool, Player memory) 
    {
        Player memory p;
        uint keyIndex = self.playerByAddress[key].keyIndex;
        if (keyIndex == 0)
            return (false,p);
        return (true, self.playerByAddress[key].player);
    }

    
    function contains(Players storage self, address key) internal view returns (bool) {
        return self.playerByAddress[key].keyIndex > 0;
    }

    function iterate_start(Players storage self) internal view returns (uint keyIndex) {
        return iterate_next(self, type(uint).max);
    }

    function iterate_valid(Players storage self, uint keyIndex) internal view returns (bool) {
        return keyIndex < self.keys.length;
    }

    function iterate_next(Players storage self, uint keyIndex) internal view returns (uint r_keyIndex) {
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
            keyIndex++;
        return keyIndex;
    }

    function iterate_get(Players storage self, uint keyIndex) internal view returns (address key, Player storage player) 
    {
        key = self.keys[keyIndex].key;
        player = self.playerByAddress[key].player;
    }
    
}
