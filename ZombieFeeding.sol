pragma ton-solidity >= 0.50.0;

import "./ZombieFactory.sol";

interface IKittyInterface {
  function getKitty(uint zombieId, uint kittyId) external view responsible returns (
        uint _zombieId,
        uint dna
  );
}

contract ZombieFeeding is ZombieFactory {
    IKittyInterface kittyContract;

    function feedAndMultiply(uint zombieId, uint targetDna) public {
        require(msg.sender == zombieToOwner[zombieId]);
        tvm.accept();
        Zombie myZombie = _zombies[zombieId];
        targetDna = targetDna % _dnaModulus;
        uint newDna = (myZombie.dna + targetDna) / 2;
        _createZombie("NoName", newDna);
    }

    function setKitty(address addr) public {
        tvm.accept();
        kittyContract = IKittyInterface(addr);
    }

    function feedOnKitty(uint zombieId, uint kittyId) public {
        tvm.accept();
        kittyContract.getKitty{
            callback: ZombieFeeding.feedAndMultiply
        }(zombieId, kittyId);
    }
}