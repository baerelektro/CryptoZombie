pragma ton-solidity ^0.51.0; //1. Здесь укажи версию Solidity
pragma AbiHeader expire; 

import "./Ownable.sol";


//2. Здесь создай контракт

contract ZombieFactory is Ownable {

    // ДНК зомби будет определяться номером из 16 цифр.
    // Задай переменную состояния uint под названием dnaDigits (номер ДНК) и установи ее значение равным 16.
    uint _dnaDigits = 16;
    // Чтобы убедиться, что ДНК зомби составляет всего 16 символов, создадим еще один uint со значением 10^16. 
    // Таким образом, мы сможем позже использовать оператор модуля % для сокращения целого числа до 16 цифр.
    uint _dnaModulus = 10 ** _dnaDigits;
    
    // Нужно каждый раз сообщать внешнему интерфейсу о создании нового зомби, чтобы приложение могло его отобразить.
    event NewZombie(uint zombieId, string name, uint dna);

    // Мы собираемся создать зомби! У них будет несколько свойств, поэтому структура подойдет как нельзя лучше.
    struct Zombie {
        string name;
        uint dna;
    }

    // Армию зомби надо разместить в массиве. Мы хотим, чтобы другие приложения видели зомби, поэтому сделаем массив открытым.
    // Создай открытый массив структур Zombie и назови его _zombies.
    Zombie[] public _zombies;
    
    // Чтобы хранить информацию о правах собственности на зомби, используем два соответствия: 
    // одно отслеживает адрес, которому принадлежит зомби, второе отслеживает, сколькими зомби владеет пользователь.
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // Чтобы начать производить зомби, зададим функцию
    function _createZombie(string name, uint dna) internal returns (uint)
    {
        // Заставим функцию createZombie что-нибудь сделать!
        _zombies.push(Zombie(name, dna));
        //  id — идентификатор зомби. _zombies.length возвращает uint новой длины массива. 
        // Поскольку первый элемент в массиве имеет индекс 0, _zombies.length - 1 вернет индекс только что добавленного зомби.
        uint id = _zombies.length - 1;
        // обновим нашу карту соответсвий zombieToOwner, чтобы сохранить msg.sender под этим id.
        zombieToOwner[id] = msg.sender;
        // увеличим ownerZombieCount для этого msg.sender.
        ownerZombieCount[msg.sender]++;
        // Вызываем эвент о создании нового зомби
        emit NewZombie(id, name, dna);
        return id;
    }

    // Нам понадобится вспомогательная функция, которая генерирует случайный номер ДНК из строки.
    // Эта функция будет просматривать определенные переменные в контракте, но не менять их. Присвой ей модификатор view (просмотр)
    function _generateDna(string name) private view returns (uint)
    {
        // Давай заполним тело функции _generateRandomDna чтобы сгенерировать случайную ДНК
        // Bзозьмём хэш от name, чтобы сгенерировать превдослучайное шестнадцатеричное число, преобразуем его в uint hash.
        uint hash = tvm.hash(name);
        // сохраним результат в uint с именем rand.
        // Мы хотим, чтобы зомби-ДНК содержала только 16(_dnaModuls) цифр 
        return hash % _dnaModulus;
    }

    // Создадим публичную функцию, которая получает на вход параметр имя зомби и использует его, чтобы создать зомби со случайной ДНК.
    function createZombie(string name) public returns (uint)
    {
        // мы не хотим, чтобы пользователь создавал неограниченное количество зомби в армии, постоянно вызывая createRandomZombie 
        // Используем require, чтобы убедиться, что функция выполняется только один раз, когда пользователь создает своего первого зомби.
        require(ownerZombieCount[msg.sender] == 0);
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
