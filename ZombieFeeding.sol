pragma ton-solidity ^0.51.0;

// Импортируй zombiefactory.sol в новый файл zombiefeeding.sol.

import "./ZombieFactory.sol";

// Интерфейс котиков возвращает ДНА котика по его ID. 
interface IKittyInterface {
    function getKitty(uint kittyId) external responsible returns (
        uint dna
    );
}

// Контракт поедания котйков наследует контракт фабрики зоби.
contract ZombieFeeding is ZombieFactory {
    
    IKittyInterface kittyContract;   
    
    mapping (uint=>uint) public feeder;

    
    function feedAndMultiply(uint zombieId, uint targetDna) public returns (uint) {
        tvm.log("feedAndMultiply:");
        tvm.hexdump(zombieId);
        tvm.hexdump(targetDna);
        //Проверяем является ли котик собственностью вызывающрго.
        require(msg.sender == zombieToOwner[zombieId]);
        // Разтршаем тратиь газ конракта.
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
        if(feeder.exists(zombieId) == false){             
            tvm.log("get Kitty...");
            feeder.add(zombieId, kittyId);
            uint128 amount = 1e8 + uint128(zombieId);
            kittyContract.getKitty{value: amount, flag: 1, callback: ZombieFeeding.logKitty}(kittyId);       
            feedAndMultiply(zombieId, kittyId);
        }else{
            uint dna = kittyId;            
        }      
    }
   
    function logKitty(uint dna) external{
        tvm.log("got Kitty");
        tvm.log("hexdump:");
        tvm.hexdump(dna);
        tvm.log("bindump:");
        tvm.bindump(dna);

        uint zombieId = msg.value - 1e8;
        tvm.log("Zombie id");        
        tvm.hexdump(zombieId);        
        tvm.bindump(zombieId);
        
        feedOnKitty(zombieId, dna);
    }
}
