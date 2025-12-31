#!/bin/bash

# Default values
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
fi

DEFAULT_ONWER_ADDRESS="0x0000000000000000000000000000000000000000"

# Take owner address and chain name
read -p "Onwer Address(default: deployer) " OWNER_ADDRESS
OWNER_ADDRESS=${OWNER_ADDRESS:-$DEFAULT_ONWER_ADDRESS}

read -p "Chain Name: " CHAIN_NAME



# export env variables:
export PRIVATE_KEY
export OWNER_ADDRESS
export CHAIN_NAME

#Run the forge script
forge script script/FaucetDeploy.s.sol:FaucetDeploy \
    --fork-url "$RPC_URL"  \
    --broadcast