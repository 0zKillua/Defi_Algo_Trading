// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/algo.sol";

contract DeployAlgoTrading is Script {

    function run() public {
        vm.startBroadcast();

        AlgoTrading algo = new AlgoTrading();
        console.log("AlgoTrading deployed at:", address(algo));


        vm.stopBroadcast();
    }
}
