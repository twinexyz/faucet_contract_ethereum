#!/bin/bash

# Default values
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
fi

DEFAULT_ENABLED="true"
DEFAULT_DROP_AMOUNT="2000000000000000000"
DEFAULT_COOLDOWN_SECONDS="86400"

# Read variables from user
read -p "Chain Name: " CHAIN_NAME
read -p "Token Address: " TOKEN_ADDRESS

read -p "Enabled (default: $DEFAULT_ENABLED): " ENABLED
ENABLED=${ENABLED:-$DEFAULT_ENABLED}

read -p "Drop Amount (default: $DEFAULT_DROP_AMOUNT): " DROP_AMOUNT
DROP_AMOUNT=${DROP_AMOUNT:-$DEFAULT_DROP_AMOUNT}

read -p "Cooldown Seconds (default: $DEFAULT_COOLDOWN_SECONDS): " COOLDOWN_SECONDS
COOLDOWN_SECONDS=${COOLDOWN_SECONDS:-$DEFAULT_COOLDOWN_SECONDS}



# export env variables:
export PRIVATE_KEY
export CHAIN_NAME
export TOKEN_ADDRESS
export ENABLED
export DROP_AMOUNT
export COOLDOWN_SECONDS

#Run the forge script
forge script script/FaucetActions.s.sol:SetTokenConfig \
    --fork-url "$RPC_URL" \
    --broadcast 