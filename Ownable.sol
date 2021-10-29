pragma ton-solidity ^0.51.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        tvm.accept();
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, 403);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        tvm.accept();
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
