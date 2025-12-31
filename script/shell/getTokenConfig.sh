#!/bin/bash

# Default values
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
fi

DEFAULT_ENABLED="true"
DEFAULT_DROP_AMOUNT="100"
DEFAULT_COOLDOWN_SECONDS="86400"

# Read variables from user
read -p "Chain Name: " CHAIN_NAME

read -p "Token Address: " TOKEN_ADDRESS

# export env variables:
export PRIVATE_KEY
export CHAIN_NAME
export TOKEN_ADDRESS

#Run the forge script
forge script script/FaucetActions.s.sol:GetTokenConfig \
    --fork-url "$RPC_URL"  \
    --broadcast