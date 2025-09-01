// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";

import {Faucet} from "src/Faucet.sol";

contract FaucetDeploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address ownerAddr = vm.envAddress("OWNER_ADDRESS");
        string memory chain = vm.envString("CHAIN_NAME");

        vm.startBroadcast(pk);
        Faucet faucet = new Faucet(ownerAddr);

        vm.stopBroadcast();

        string memory faucetObj = "Deployedcontract";
        string memory json = vm.serializeAddress(
            faucetObj,
            "faucetContract",
            address(faucet)
        );
        string memory fileName = string(
            abi.encodePacked("./script/utils/Deployedcontract_", chain, ".json")
        );

        vm.writeJson(json, fileName);

        console.log("Faucet Deployed to :", address(faucet));
        console.log("Network", chain);
    }
}
