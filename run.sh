#!/usr/bin/env bash

tondev se reset

rm -fr *.abi.json *.tvc

# deploy stub of Kitty Contract
tondev sol compile KittyInterface.sol
tondev contract deploy KittyInterface --value 1000000000
kittyAddress=$(tondev contract info KittyInterface | grep Address | cut -d':' -f3 | cut -d' ' -f1)
echo "$kittyAddress"

# deploy of Zombie Contract
tondev sol compile ZombieFeeding.sol
tondev contract deploy ZombieFeeding --value 1000000000
zombieAddress=$(tondev contract info ZombieFeeding | grep Address | cut -d':' -f3 | cut -d' ' -f1)
echo "$zombieAddress"
tondev contract run ZombieFeeding --address "$zombieAddress" setKittyContractAddress --input "addr:$kittyAddress"

# interact

tondev contract run ZombieFeeding createZombie --input "name:foo"
tondev contract run-local ZombieFeeding zombieCount
tondev contract run-local ZombieFeeding getZombieName --input "id:0"
tondev contract run-local ZombieFeeding getZombieDna --input "id:0"
tondev contract run-local KittyInterface getKitty --input "kittyId:0,answerId:0"
tondev contract run ZombieFeeding feedOnKitty --input "zombieId:0,kittyId:0"
tondev contract run-local ZombieFeeding zombieCount
