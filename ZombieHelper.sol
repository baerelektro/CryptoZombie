pragma ton-solidity ^0.51.0;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    uint _levelUpFee = 0.001 ton;

    modifier aboveLevel(uint level, uint zombieId) {
        require(_zombies[zombieId].level >= level);
        _;
    }

    function levelUp(uint zombieId) external {
        tvm.rawReserve(address(this).balance - msg.value + _levelUpFee, 0);
        _zombies[zombieId].level++;
        msg.sender.transfer(0, true, 128);
    }

// TODO function withdraw() external onlyOwner {
//        owner.transfer(this.balance);
//    }

    function setLevelUpFee(uint fee) external onlyOwner {
        _levelUpFee = fee;
    }

    function changeName(uint zombieId, string newName) external aboveLevel(2, zombieId) {
        require(zombieToOwner[zombieId] == msg.sender, 105);
        tvm.accept();
        _zombies[zombieId].name = newName;
    }

    function changeDna(uint zombieId, uint newDna) external aboveLevel(20, zombieId) {
        require(zombieToOwner[zombieId] == msg.sender, 106);
        tvm.accept();
        _zombies[zombieId].dna = newDna;
    }

    function getZombiesByOwner(address owner) external view returns(uint[])
    {
        uint[] result = new uint[](ownerZombieCount[owner]);
        uint counter = 0;

        for (uint256 index = 0; index < _zombies.length; index++) {
            if (zombieToOwner[index] == owner) {
                result[counter] = index;
                counter++;
            }
        }

        return result;
    }
}
