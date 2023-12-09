// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import "../src/ImpactDAO.sol";
import "../src/ImpactDAOToken.sol";
import "../src/ImpactRewardToken.sol";

import "../src/ImpactMarketplace.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address Admin = msg.sender;

        ImpactDAOToken Token = new ImpactDAOToken(Admin, "token Uri");
        ImpactRewardsToken rewardee = new ImpactRewardsToken();
        ImpactDAO impactDao = new ImpactDAO(Admin, address(Token), address(rewardee));
        ImpactMarketPlace marketplace = new ImpactMarketPlace(address(Token), address(rewardee));

        console2.logString("Admin");
        console2.logAddress(Admin);
        console2.logString("Dao Token");
        console2.logAddress(address(Token));
        console2.logString("Rewardee Token");
        console2.logAddress(address(rewardee));
        console2.logString("Dao Contract");
        console2.logAddress(address(impactDao));
        console2.logString("Marketplace Contract");
        console2.logAddress(address(marketplace));

        vm.stopBroadcast();
    }
}
