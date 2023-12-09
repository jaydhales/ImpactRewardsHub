// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ImpactMarketplace.sol";

contract ImpactMarketplaceScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ImpactMarketPlace marketplace = new ImpactMarketPlace(
            0x7cD28B73D8AFe3219D742178f2660eC3D018A5E4,
            0x3aaCcC7C02763BFfCC01EB6F2958aF6FE0a9248B
        );

        vm.stopBroadcast();
    }
}

// ImpactMarketplace CONTRACT: 0xeA654760768D99A2cf54E37A65200024957Ebd5c
