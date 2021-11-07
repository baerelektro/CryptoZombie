pragma ton-solidity ^0.51.0;

import "./ZombieFactory.sol";

interface IKittyInterface {
    function getKitty(uint kittyId) external responsible returns (
        uint dna
    );
}

contract ZombieFeeding is ZombieFactory {
    IKittyInterface kittyContract;

    function feedAndMultiply(uint zombieId, uint targetDna) public returns (uint) {
        tvm.log("feedAndMultiply:");
        tvm.hexdump(zombieId);
        tvm.hexdump(targetDna);
        require(msg.sender == zombieToOwner[zombieId]);
        tvm.accept();
        Zombie myZombie = _zombies[zombieId];
        targetDna = targetDna % _dnaModulus;
        uint newDna = (myZombie.dna + targetDna) / 2;
        return _createZombie("NoName", newDna);
    }

    function setKittyContractAddress(address addr) public onlyOwner {
        tvm.accept();
        kittyContract = IKittyInterface(addr);
    }

    function feedOnKitty(uint zombieId, uint kittyId) public {
        tvm.accept();
        tvm.log("get Kitty...");
        kittyContract.getKitty{value: 1e8, callback: ZombieFeeding.logKitty}(kittyId);       
        feedAndMultiply(zombieId, kittyId);
    }

    function logKitty(uint dna) public{
        tvm.log("got Kitty");
        tvm.log("hexdump:");
        tvm.hexdump(dna);
        tvm.log("bindump:");
        tvm.bindump(dna);
    }
}
