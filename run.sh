#!/usr/bin/env bash

tondev se reset

rm -fr *.abi.json *.tvc

# deploy stub of Kitty Contract
tondev sol compile KittyInterface.sol
tondev contract deploy KittyInterface --value 1000000000
kittyAddress=$(tondev contract info KittyInterface | grep Address | cut -d':' -f3 | cut -d' ' -f1)
echo "$kittyAddress"

# deploy of Zombie Contract
tondev sol compile ZombieHelper.sol
tondev contract deploy ZombieHelper --value 1000000000
zombieAddress=$(tondev contract info ZombieHelper | grep Address | cut -d':' -f3 | cut -d' ' -f1)
echo "$zombieAddress"
tondev contract run ZombieHelper --address "$zombieAddress" setKittyContractAddress --input "addr:$kittyAddress"

# interact

tondev contract run ZombieHelper createZombie --input "name:foo"
tondev contract run-local ZombieHelper zombieCount
tondev contract run-local ZombieHelper getZombieName --input "id:0"
tondev contract run-local ZombieHelper getZombieDna --input "id:0"
tondev contract run-local KittyInterface getKitty --input "kittyId:0,answerId:0,zombieId:0"
tondev contract run ZombieHelper feedOnKitty --input "zombieId:0,kittyId:0"
tondev contract run-local ZombieHelper zombieCount
tondev contract run-local ZombieHelper getZombiesByOwner --input "owner:0000000000000000000000000000000000000000000000000000000000000000"
