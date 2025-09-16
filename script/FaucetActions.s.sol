// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";

import {Faucet} from "src/Faucet.sol";

contract SetTokenConfig is Script {
    Faucet faucet;
    address payable faucetAddress;

    address token;
    bool enabled;
    uint256 dropAmount;
    uint256 cooldownSeconds;

    function setUp() public {
        // Read env varaibles
        string memory chain = vm.envString("CHAIN_NAME");
        token = vm.envAddress("TOKEN_ADDRESS");
        enabled = vm.envBool("ENABLED");
        dropAmount = vm.envUint("DROP_AMOUNT");
        cooldownSeconds = vm.envUint("COOLDOWN_SECONDS");

        // Read JSON file contents
        string memory path = string(
            abi.encodePacked("./script/utils/Deployedcontract_", chain, ".json")
        );

        string memory json = vm.readFile(path);
        faucetAddress = payable(vm.parseJsonAddress(json, ".faucetContract"));
        faucet = Faucet(faucetAddress);

       
    }

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        faucet.setTokenConfig(token, enabled, dropAmount, cooldownSeconds);

        vm.stopBroadcast();
    }
}

contract GetTokenConfig is Script {
    Faucet faucet;
    address payable faucetAddress;

    address token;

     function setUp() public {
        // Read parameters
        string memory chain = vm.envString("CHAIN_NAME");
        token = vm.envAddress("TOKEN_ADDRESS");
        
        // Read JSON file contents
        string memory path = string(
            abi.encodePacked("./script/utils/Deployedcontract_", chain, ".json")
        );

        string memory json = vm.readFile(path);
        faucetAddress = payable(vm.parseJsonAddress(json, ".faucetContract"));
        faucet = Faucet(faucetAddress);

    }

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        Faucet.TokenConfig memory config = faucet.getTokenConfig(token);

        console.log("Token:         : ", token);
        console.log("Enabled        : ", config.enabled);
        console.log("dropAmount     : ", config.dropAmount);
        console.log("cooldown       : ", config.cooldownSeconds);
        
        vm.stopBroadcast();
    }
}

contract Claim is Script {
    Faucet faucet;
    address payable faucetAddress;

    address token;
    address to;

     function setUp() public {
        // Read parameters
        string memory chain = vm.envString("CHAIN_NAME");
        token = vm.envAddress("TOKEN_ADDRESS");
        to = vm.envAddress("RECEIVER");
        
        // Read JSON file contents
        string memory path = string(
            abi.encodePacked("./script/utils/Deployedcontract_", chain, ".json")
        );

        string memory json = vm.readFile(path);
        faucetAddress = payable(vm.parseJsonAddress(json, ".faucetContract"));
        faucet = Faucet(faucetAddress);
    }

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        faucet.claim(token, to);

        vm.stopBroadcast();
    }
}