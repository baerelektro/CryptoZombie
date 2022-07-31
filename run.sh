#!/usr/bin/env bash

everdev se reset

rm -fr *.abi.json *.tvc

wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.tvc
wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.abi.json

everdev signer generate alice || true
alicePK="0x$(tondev signer info alice | jq -r .keys.public)"
everdev contract deploy --signer alice SafeMultisigWallet --value 100000000000 --input "owners:[$alicePK],reqConfirms:1"

everdev signer generate bob || true
bobPK="0x$(everdev signer info bob | jq -r .keys.public)"
everdev contract deploy --signer bob SafeMultisigWallet --value 100000000000 --input "owners:[$bobPK],reqConfirms:1"

# deploy stub of Kitty Contract
everdev sol compile KittyInterface.sol
everdev contract deploy KittyInterface --value 1000000000
kittyAddress=$(everdev contract info KittyInterface | grep Address | cut -d':' -f3 | cut -d' ' -f1)
echo "$kittyAddress"

# deploy of Zombie Contract
everdev sol compile ZombieHelper.sol
everdev contract deploy ZombieHelper --value 1000000000
zombieAddress=$(everdev contract info ZombieHelper | grep Address | cut -d':' -f3 | cut -d' ' -f1)
echo "$zombieAddress"
everdev contract run ZombieHelper --address "$zombieAddress" setKittyContractAddress --input "addr:$kittyAddress"

# interact

everdev contract run ZombieHelper createZombie --input "name:foo"
everdev contract run-local ZombieHelper zombieCount
everdev contract run-local ZombieHelper getZombie --input "id:0"

tonos-cli --url localhost account $zombieAddress | grep balance
body=$(tonos-cli body --abi ZombieHelper.abi.json levelUp '{"zombieId":"0"}' | grep body | cut -d' ' -f3)
input="dest:'0:$zombieAddress',value:1000000000,allBalance:false,bounce:false,payload:'$body'"
echo "input=$input"
everdev contract run --signer bob SafeMultisigWallet submitTransaction --input "$input"
tonos-cli --url localhost account $zombieAddress | grep balance
everdev contract run-local ZombieHelper getZombie --input "id:0"

#everdev contract run ZombieHelper levelUp --input "zombieId:0"
#tonos-cli body --abi ZombieHelper.abi.json levelUp '{"zombieId":"0"}'
#cd /home/ilyar/project/ton/ton-labs-contracts/solidity/safemultisig &&\
# everdev contract run SafeMultisigWallet submitTransaction --input "dest:'0:7dea5d21c0f4cc911ec2a3dedf3506a8ee27183880f95f2c45a65e29b8a793d3',value:100000,allBalance:false,bounce:false,payload:'te6ccgEBAQEAJgAASA6Nr8UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=='"

#everdev contract run-local ZombieHelper getZombieName --input "id:0"
#everdev contract run-local ZombieHelper getZombieDna --input "id:0"
#everdev contract run-local KittyInterface getKitty --input "kittyId:0,answerId:0,zombieId:0"
#everdev contract run ZombieHelper feedOnKitty --input "zombieId:0,kittyId:0"
#everdev contract run-local ZombieHelper zombieCount
#everdev contract run-local ZombieHelper getZombiesByOwner --input "owner:0000000000000000000000000000000000000000000000000000000000000000"
