# Update default values
updateDefaultValues:
	bash script/shell/updateDefaultValues.sh

# Deploy the faucet contract
deployContract:
	bash script/shell/deployContract.sh

# Set token configuration for a token
setTokenConfig:
	bash script/shell/setTokenConfig.sh

# Get configuration of a token
getTokenConfig:
	bash script/shell/getTokenConfig.sh

# Claim airdrop
claim:
	bash script/shell/claim.sh