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

        ImpactDAOToken Token = ImpactDAOToken(0x12B9FceD944c68660F7b820c3f2d49cF268855d9);
        ImpactRewardsToken rewardee = ImpactRewardsToken(0x1453E47D458a3Deda26Ce03d0EB3Cc0E6b99955F);
        ImpactDAO impactDao = new ImpactDAO(Admin, address(Token), address(rewardee));

        console2.logString("Dao Contract");
        console2.logAddress(address(impactDao));

        impactDao.resetVoteTime(300);

        vm.stopBroadcast();
    }
}

// forge script script/DeployOnlyDao.s.sol  --rpc-url https://eth-sepolia.g.alchemy.com/v2/wUESb5BYyxmKb8Tb4ZFejvE369DlO39P --account defaultKey --sender <publickey> --verify   --etherscan-api-key <etherscan-key> --broadcast
