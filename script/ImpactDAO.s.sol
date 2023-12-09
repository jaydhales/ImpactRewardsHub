// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ImpactDAO.sol";

contract ImpactDAOScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ImpactDAO impactdao = new ImpactDAO(
            0xA003A9A2E305Ff215F29fC0b7b4E2bb5a8C2F3e1,
            0x7cD28B73D8AFe3219D742178f2660eC3D018A5E4,
            0x3aaCcC7C02763BFfCC01EB6F2958aF6FE0a9248B
        );

        vm.stopBroadcast();
    }
}

// ADMIN: 0xA003A9A2E305Ff215F29fC0b7b4E2bb5a8C2F3e1
// ImpactDAO CONTRACT: 0x8a18c466229B0D78cE013314Af5505A5aD6924bF
