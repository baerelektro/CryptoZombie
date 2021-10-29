pragma ton-solidity ^0.51.0;
pragma AbiHeader expire;

import "./Ownable.sol";

contract ZombieFactory is Ownable {
    uint _dnaDigits = 16;
    uint _dnaModulus = 10 ** _dnaDigits;

    event NewZombie(uint zombieId, string name, uint dna);

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public _zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string name, uint dna) internal returns (uint)
    {
        _zombies.push(Zombie(name, dna));
        uint id = _zombies.length - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, name, dna);
        return id;
    }

    function _generateDna(string name) private view returns (uint)
    {
        uint hash = tvm.hash(name);
        return hash % _dnaModulus;
    }

    function createZombie(string name) public returns (uint)
    {
        tvm.accept();
        uint randDna = _generateDna(name);
        return _createZombie(name, randDna);
    }

    function getZombieDna(uint id) public view returns (uint)
    {
        return _zombies[id].dna;
    }

    function getZombieName(uint id) public view returns (string)
    {
        return _zombies[id].name;
    }

    function zombieCount() public view returns (uint)
    {
        return _zombies.length;
    }
}
