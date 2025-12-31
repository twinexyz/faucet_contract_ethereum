#!/bin/bash

# Default values
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
fi

# Read variables from user
read -p "Chain Name: " CHAIN_NAME

read -p "Token Address: " TOKEN_ADDRESS

read -p "Receiver Address" RECEIVER

# export env variables:
export PRIVATE_KEY
export CHAIN_NAME
export TOKEN_ADDRESS
export RECEIVER

#Run the forge script
forge script script/FaucetActions.s.sol:Claim \
    --fork-url "$RPC_URL"  \
    --broadcast