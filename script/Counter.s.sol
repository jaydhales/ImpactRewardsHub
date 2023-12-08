// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import "../src/ImpactDAO.sol";
import "../src/ImpactDAOToken.sol";
import "../src/ImpactRewardToken.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address Admin = msg.sender;

        ImpactDAOToken Token = new ImpactDAOToken(Admin, "token Uri");
        ImpactRewardsToken rewardee = new ImpactRewardsToken();
        ImpactDAO impactDao = new ImpactDAO(Admin, address(Token), address(rewardee));

        console2.logAddress(msg.sender);
        console2.logAddress(Admin);
        console2.logAddress(address(Token));
        console2.logAddress(address(rewardee));
        console2.logAddress(address(impactDao));

        vm.stopBroadcast();
    }
}
//  0xa2b058528741AFC93631B26F1f71546dAa1B7f34 // TOKEN
//   0x9e609f87336adf22D19E573417cf00e44Bec194a // REWARD
//   0xcD81aFBAb25A58381B7DDcC1884839Ea26eAE784 // DAO
