// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Final {
    uint public currentBetId;
    uint public betPrice;

    struct Position {
        uint betId;
        address walletAddress;
        uint gameResult;
        bool payed;
    }

    Position position;

    mapping(uint => Position) public betInfo;
    mapping(uint => uint[]) public gameValues;
    mapping(uint => uint[]) public userValues;
    mapping(address => uint[]) public betIdsByAddress;

    constructor() {
        currentBetId = 0;
        betPrice = 1;
    }

    function checkAddress(address _betterAddress) public view returns (uint){
        return betIdsByAddress[_betterAddress].length;
    }

    function makeBet(address _betterAddress, uint userValue1, uint userValue2, uint userValue3, uint userValue4, uint userValue5) external payable {
        if (_betterAddress.balance >= (betPrice * 10000000000000000)) {
            (uint gameResult, uint[5] memory tempGameValues) = playGame(userValue1, userValue2, userValue3, userValue4, userValue5);
            
            betInfo[currentBetId] = Position(
                currentBetId,
                _betterAddress,
                gameResult,
                false
            );

            userValues[currentBetId] = [userValue1, userValue2, userValue3, userValue4, userValue5];
            gameValues[currentBetId] = tempGameValues;

            betIdsByAddress[_betterAddress].push(currentBetId);
            currentBetId += 1;
        }
    }

    function getRandomNumber() public view returns (uint, uint, uint, uint, uint) {
        uint random1 = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 99 + 1;
        uint random2 = uint(keccak256(abi.encodePacked(tx.origin, blockhash(block.number - 1), block.timestamp))) % 99 + 1;
        if (random2 == random1){
            random2++;
            if (random2 == 100){
                random2 = 1;
            }
        }
        uint random3 = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 99 + 1;
        if (random3 == random1 || random3 == random2){
            random3 += 2;
            if (random2 >= 100){
                random2 = 2;
            }
        }
        uint random4 = uint(keccak256(abi.encodePacked(tx.origin, block.timestamp, block.number, block.prevrandao, msg.sender))) % 99 + 1;
        if (random4 == random1 || random4 == random2 || random4 == random3){
            random4 += 3;
            if (random4 >= 100){
                random4 = 3;
            }
        }
        uint random5 = uint(keccak256(abi.encodePacked(tx.origin, block.timestamp, block.number, block.prevrandao, msg.sender, block.timestamp))) % 99 + 1;
        if (random5 == random1 || random5 == random2 || random5 == random3 || random5 == random4){
            random5 += 4;
            if (random5 >= 100){
                random5 = 4;
            }
        }
        return (random1, random2, random3, random4, random5);
    }

    function playGame(uint userValue1, uint userValue2, uint userValue3, uint userValue4, uint userValue5) public view returns (uint, uint[5] memory){
        uint gameResult = 0;
        (uint gameValue1, uint gameValue2, uint gameValue3, uint gameValue4, uint gameValue5) = getRandomNumber();
        uint[5] memory tempGameValues;
        tempGameValues = [gameValue1, gameValue2, gameValue3, gameValue4, gameValue5];
        uint a = 0;
        while(a < 5) {
            if (tempGameValues[a] == userValue1) {
                gameResult += 1;
            }
            if (tempGameValues[a] == userValue2) {
                gameResult += 1;
            }
            if (tempGameValues[a] == userValue3) {
                gameResult += 1;
            }
            if (tempGameValues[a] == userValue4) {
                gameResult += 1;
            }
            if (tempGameValues[a] == userValue5) {
                gameResult += 1;
            }
            a += 1;
        }
        return (gameResult, tempGameValues);
    }

    function getReward(address _betterAddress) public {
        uint a = 0;
        bool success;
        while (a < betIdsByAddress[_betterAddress].length) {
            uint betId = betIdsByAddress[_betterAddress][a];
            bool payed = betInfo[betId].payed;
            if (!payed) {
                uint result = betInfo[betId].gameResult;
                if (result == 1){
                    (bool sent,) = _betterAddress.call{value: ((betPrice * 10000000000000000) / 2)}("");
                    require(sent,"failed to send");
                    success = sent;
                }
                if (result == 2){
                    (bool sent,) = _betterAddress.call{value: (betPrice * 10000000000000000)}("");
                    require(sent,"failed to send");
                    success = sent;
                }
                if (result == 3){
                    (bool sent,) = _betterAddress.call{value: ((betPrice * 2) * 10000000000000000)}("");
                    require(sent,"failed to send");
                    success = sent;
                }
                if (result == 4){
                    (bool sent,) = _betterAddress.call{value: ((betPrice * 5) * 10000000000000000)}("");
                    require(sent,"failed to send");
                    success = sent;
                }
                if (result == 5){
                    (bool sent,) = _betterAddress.call{value: ((betPrice * 10) * 10000000000000000)}("");
                    require(sent,"failed to send");
                    success = sent;
                }
            }
            a += 1;
        }
        if (success) {
            uint b = 0;
            while (b < betIdsByAddress[_betterAddress].length) {
                uint betId = betIdsByAddress[_betterAddress][b];
                betInfo[betId].payed = true;
                b += 1;
            }
        }
    }
}