#!/bin/bash

# Default values
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
DEFAULT_FORK_URL="127.0.0.1:8545"
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
    --fork-url $DEFAULT_FORK_URL  \
    --broadcast \
    -- --env "PRIVATE_KEY=$PRIVATE_KEY" --env "CHAIN_NAME=$CHAIN_NAME" --evn "TOKEN_ADDRESS=$TOKEN_ADDRESS" \
    --env "ENABLED=$ENABLED" --env "DROP_AMOUNT=$DROP_AMOUNT" --env "COOLDOWN_SECONDS=$COOLDOWN_SECONDS"