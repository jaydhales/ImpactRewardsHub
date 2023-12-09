// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ImpactRewardToken.sol";

contract ImpactRewardScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ImpactRewardsToken impactrewardstoken = new ImpactRewardsToken();

        vm.stopBroadcast();
    }
}

// ImpactRewardToken CONTRACT: 0x3aaCcC7C02763BFfCC01EB6F2958aF6FE0a9248B
