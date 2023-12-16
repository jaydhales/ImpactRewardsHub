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

        address[] memory members = new address[](5);
        members[0] = Admin;
        members[1] = 0x764693DD666E8dD9275CDE8F05C6B07446B1d941;
        members[2] = 0xA003A9A2E305Ff215F29fC0b7b4E2bb5a8C2F3e1;
        members[3] = 0x30F14795e20d81703304B61835376cF18d7304Bb;
        members[4] = 0x82f2fBF5617F6D7AfE9AB0C6E5e65dB52D1fb563;

        Token.safeMint(members);

        vm.stopBroadcast();
    }
}

// forge script script/Counter.s.sol  --rpc-url https://eth-sepolia.g.alchemy.com/v2/wUESb5BYyxmKb8Tb4ZFejvE369DlO39P --account defaultKey --sender <publickey> --verify   --etherscan-api-key <etherscan-key> --broadcast
