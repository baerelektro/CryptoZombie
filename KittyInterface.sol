pragma ton-solidity >= 0.50.0;

contract KittyInterface {
    function getKitty(uint zombieId, uint kittyId) external view returns (
        uint _zombieId,
        uint dna
    ) {
        return (zombieId, 42);
        // Kitty storage kit = kitties[_id];

        // // Если эта переменная равна нулю, то она не беременеет:)
        // isGestating = (kit.siringWithId != 0);
        // isReady = (kit.cooldownEndBlock <= block.number);
        // cooldownIndex = uint256(kit.cooldownIndex);
        // nextActionAt = uint256(kit.cooldownEndBlock);
        // siringWithId = uint256(kit.siringWithId);
        // birthTime = uint256(kit.birthTime);
        // matronId = uint256(kit.matronId);
        // sireId = uint256(kit.sireId);
        // generation = uint256(kit.generation);
        // genes = kit.genes;
    }
}