pragma ton-solidity >= 0.51.0;


// Импортируй zombiefactory.sol в новый файл zombiefeeding.sol.

import "./ZombieFactory.sol";

// Интерфейс котиков возвращает ДНА котика по его ID. 
interface IKittyInterface {
    function getKitty(uint zombieId, uint kittyId) external responsible returns (
        uint,
        uint
    );
}

// Контракт поедания котйков наследует контракт фабрики зоби.
contract ZombieFeeding is ZombieFactory {
    
    IKittyInterface kittyContract;

    function feedAndMultiply(uint zombieId, uint targetDna) public {
        tvm.log("feedAndMultiply:");
        tvm.hexdump(zombieId);
        tvm.hexdump(targetDna);
        //Проверяем является ли котик собственностью вызывающрго.
        require(msg.sender == zombieToOwner[zombieId]);
        // Разтршаем тратиь газ конракта.
        tvm.accept();
        
        Zombie myZombie = _zombies[zombieId];
        tvm.log("before _isReady");
        require(_isReady(myZombie), 104);
        tvm.log("after _isReady");
        targetDna = targetDna % _dnaModulus;
        uint newDna = (myZombie.dna + targetDna) / 2;
        tvm.log("before _triggerCooldown");
        _triggerCooldown(myZombie);
        tvm.log("after _triggerCooldown");
        
        _createZombie("NoName", newDna);
    }

    function setKittyContractAddress(address addr) public onlyOwner {
        tvm.accept();
        kittyContract = IKittyInterface(addr);
    }

    function feedOnKitty(uint zombieId, uint kittyId) public {
        tvm.accept();
        tvm.log("get Kitty...");
        kittyContract.getKitty{
            callback: ZombieFeeding.feedAndMultiply
        }(zombieId, kittyId);
        // tvm.log("got Kitty");
        // tvm.log("hexdump:");
        // tvm.hexdump(dna);
        // tvm.log("bindump:");
        // tvm.bindump(dna);
        feedAndMultiply(zombieId, kittyId);
    }
}
