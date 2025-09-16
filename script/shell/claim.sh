#!/bin/bash

# Default values
PRIVATE_KEY="0x63ff47b31d047d471229d35e0e2b829708dde1f1e438bfaf1059d0de785dedc1"
DEFAULT_FORK_URL="https://ethereum-sepolia-rpc.publicnode.com"

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
    --fork-url $DEFAULT_FORK_URL  \
    --broadcast \
    -- --env "PRIVATE_KEY=$PRIVATE_KEY" --env "CHAIN_NAME=$CHAIN_NAME" --evn "TOKEN_ADDRESS=$TOKEN_ADDRESS" \
    --env "RECEIVER=$RECEIVER"