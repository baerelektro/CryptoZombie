
pragma ton-solidity >= 0.50.0;
pragma AbiHeader expire;

contract ZombieFactory {
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

    constructor () public {
        tvm.accept();
    }

    function _createZombie(string name, uint dna) internal
    {
        _zombies.push(Zombie(name, dna));
        uint id = _zombies.length - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, name, dna);
    }

    function getAddr() public pure returns (address addr) {
        tvm.accept();
        return msg.sender;
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
        _createZombie(name, randDna);
        return _zombies.length - 1;
    }

    function getZombieDna(uint id) public view returns (uint)
    {
        tvm.accept();
        return _zombies[id].dna;
    }

    function getZombieName(uint id) public view returns (string)
    {
        tvm.accept();
        return _zombies[id].name;
    }

    function zombieCount() public view returns (uint)
    {
        tvm.accept();
        return _zombies.length;
    }
}