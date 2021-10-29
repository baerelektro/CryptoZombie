#!/usr/bin/env bash

set -o errexit

npm install -g tondev

tondev sol update
tondev network default se
tondev signer add giver 172af540e43a524763dd53b26a066d472a97c4de37d5498170564510608250c3
tondev network giver se 0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5 --signer giver
tondev signer generate owner
tondev signer default owner
