#!/usr/bin/env bash

tonos-cli config --url net.ton.dev

rm -fr *.abi.json *.tvc

wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.tvc
wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.abi.json

Giver_Addr=$(tonos-cli genaddr SafeMultisigWallet.tvc SafeMultisigWallet.abi.json --setkey giverkey.json --wc 0 | grep "Raw address:" | awk '{print $3}')
echo "Giver: $Giver_Addr"
Giver_Pub=$(cat giverkey.json | grep "public" |  awk '{print $2}'  | tr -d \" | tr -d , )
echo "Pub: $Giver_Pub"


Alice_Addr=$(tonos-cli genaddr SafeMultisigWallet.tvc SafeMultisigWallet.abi.json --genkey alicekey.json --wc 0 | grep "Raw address:" | awk '{print $3}')
echo "Alice: $Alice_Addr"
Alice_Pub=$(cat alicekey.json | grep "public" |  awk '{print $2}'  | tr -d \" | tr -d , )
echo "Pub: $Alice_Pub"
tonos-cli call $Giver_Addr submitTransaction '{"dest":"'$Alice_Addr'","value":1000000000,"bounce":false,"allBalance":false,"payload":""}' --abi SafeMultisigWallet.abi.json --sign giverkey.json
tonos-cli deploy --sign alicekey.json --wc 0 --abi SafeMultisigWallet.abi.json SafeMultisigWallet.tvc '{"owners":["0x'$Alice_Pub'"],"reqConfirms":1}'

Bob_Addr=$(tonos-cli genaddr SafeMultisigWallet.tvc SafeMultisigWallet.abi.json --genkey bobkey.json --wc 0 | grep "Raw address:" | awk '{print $3}')
echo "Bob: $Bob_Addr"
Bob_Pub=$(cat bobkey.json | grep "public" |  awk '{print $2}'  | tr -d \" | tr -d , )
echo "Pub: $Bob_Pub"
tonos-cli call $Giver_Addr submitTransaction '{"dest":"'$Bob_Addr'","value":1000000000,"bounce":false,"allBalance":false,"payload":""}' --abi SafeMultisigWallet.abi.json --sign giverkey.json
tonos-cli deploy --sign bobkey.json --wc 0 --abi SafeMultisigWallet.abi.json SafeMultisigWallet.tvc '{"owners":["0x'$Bob_Pub'"],"reqConfirms":1}'


# deploy stub of Kitty Contract
solc KittyInterface.sol
tvm_linker compile KittyInterface.code -o KittyInterface.tvc --abi-json KittyInterface.abi.json -w 0
kittyAddress=$(tonos-cli genaddr KittyInterface.tvc KittyInterface.abi.json --genkey kittykey.json --wc 0 | grep "Raw address:" | awk '{print $3}')
echo "Kitty: $kittyAddress"
Kitty_Pub=$(cat kittykey.json | grep "public" |  awk '{print $2}'  | tr -d \" | tr -d , )
echo "Pub: $Kitty_Pub"

tonos-cli call $Giver_Addr submitTransaction '{"dest":"'$kittyAddress'","value":1000000000,"bounce":false,"allBalance":false,"payload":""}' --abi SafeMultisigWallet.abi.json --sign giverkey.json
tonos-cli deploy --sign kittykey.json --wc 0 --abi KittyInterface.abi.json KittyInterface.tvc '{"owners":["0x'$Kitty_Pub'"],"reqConfirms":1}'


# deploy of Zombie Contract

solc  ZombieHelper.sol
tvm_linker compile ZombieHelper.code -o ZombieHelper.tvc --abi-json ZombieHelper.abi.json -w 0
zombieAddress=$(tonos-cli genaddr ZombieHelper.tvc ZombieHelper.abi.json --genkey zombiekey.json --wc 0 | grep "Raw address:" | awk '{print $3}')
echo "Zombie: $zombieAddress"
Zombie_Pub=$(cat zombiekey.json | grep "public" |  awk '{print $2}'  | tr -d \" | tr -d , )
echo "Pub: $Zombie_Pub"
tonos-cli call $Giver_Addr submitTransaction '{"dest":"'$zombieAddress'","value":1000000000,"bounce":false,"allBalance":false,"payload":""}' --abi SafeMultisigWallet.abi.json --sign giverkey.json
tonos-cli deploy --sign zombiekey.json --wc 0 --abi ZombieHelper.abi.json ZombieHelper.tvc '{"owners":["0x'$Zombie_Pub'"],"reqConfirms":1}'

tonos-cli call --abi ZombieHelper.abi.json $zombieAddress setKittyContractAddress '{"addr": "'$kittyAddress'"}' --sign zombiekey.json

# interact
# tonos-cli call --abi ZombieHelper.abi.json $zombieAddress createZombie '{"name": "foo"}' --sign zombiekey.json
# tonos-cli call --abi ZombieHelper.abi.json $zombieAddress zombieCount '{}' --sign zombiekey.json
# tonos-cli call --abi ZombieHelper.abi.json $zombieAddress getZombie '{"id": 0}' --sign zombiekey.json

# tondev contract run ZombieHelper createZombie --input "name:foo"
# tondev contract run-local ZombieHelper zombieCount
# tondev contract run-local ZombieHelper getZombie --input "id:0"

# tonos-cli --url localhost account $zombieAddress | grep balance
# body=$(tonos-cli body --abi ZombieHelper.abi.json levelUp '{"zombieId":"0"}' | grep body | cut -d' ' -f3)
# input="dest:'0:$zombieAddress',value:1000000000,allBalance:false,bounce:false,payload:'$body'"
# echo "input=$input"
# tondev contract run --signer bob SafeMultisigWallet submitTransaction --input "$input"
# tonos-cli --url localhost account $zombieAddress | grep balance
# tondev contract run-local ZombieHelper getZombie --input "id:0"

#tondev contract run ZombieHelper levelUp --input "zombieId:0"
#tonos-cli body --abi ZombieHelper.abi.json levelUp '{"zombieId":"0"}'
#cd /home/ilyar/project/ton/ton-labs-contracts/solidity/safemultisig &&\
# tondev contract run SafeMultisigWallet submitTransaction --input "dest:'0:7dea5d21c0f4cc911ec2a3dedf3506a8ee27183880f95f2c45a65e29b8a793d3',value:100000,allBalance:false,bounce:false,payload:'te6ccgEBAQEAJgAASA6Nr8UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=='"

#tondev contract run-local ZombieHelper getZombieName --input "id:0"
#tondev contract run-local ZombieHelper getZombieDna --input "id:0"
#tondev contract run-local KittyInterface getKitty --input "kittyId:0,answerId:0,zombieId:0"
#tondev contract run ZombieHelper feedOnKitty --input "zombieId:0,kittyId:0"
#tondev contract run-local ZombieHelper zombieCount
#tondev contract run-local ZombieHelper getZombiesByOwner --input "owner:0000000000000000000000000000000000000000000000000000000000000000"
