#!/usr/bin/env bash

tonos-cli config --url net.ton.dev

rm -fr *.abi.json *.tvc

wget https://raw.githubusercontent.com/tonlabs/tonos-se/master/contracts/giver_v2/GiverV2.abi.json
wget https://raw.githubusercontent.com/tonlabs/tonos-se/master/contracts/giver_v2/GiverV2.keys.json
wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.tvc
wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/5ee039e4d093b91b6fdf7d77b9627e2e7d37f000/solidity/safemultisig/SafeMultisigWallet.abi.json

Giver_Addr=$(tonos-cli genaddr SafeMultisigWallet.tvc SafeMultisigWallet.abi.json --genkey giverkey.json --wc 0 | grep "Raw address:" | awk '{print $3}')
echo "Giver: $Giver_Addr"
Giver_Pub=$(cat giverkey.json | grep "public" |  awk '{print $2}'  | tr -d \" | tr -d , )
echo "Pub: $Giver_Pub"

tonos-cli call 0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5 \
    sendTransaction '{"dest":"'$Giver_Addr'","value":5000000000,"bounce":false}' \
    --abi GiverV2.abi.json \
    --sign GiverV2.keys.json

tonos-cli deploy --sign giverkey.json  --wc 0 --abi SafeMultisigWallet.abi.json SafeMultisigWallet.tvc '{"owners":["0x'$Giver_Pub'"],"reqConfirms":1}'


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
