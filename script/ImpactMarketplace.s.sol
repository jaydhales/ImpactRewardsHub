// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ImpactMarketplace.sol";

contract ImpactMarketplaceScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ImpactMarketPlace marketplace = new ImpactMarketPlace(
            0xE5935E7f16Cc910Cf20B6af95BB510BEB272595e,
            0x668062cDb83fdd2871b55d2d43eD539B783E6A67
        );

        vm.stopBroadcast();
    }
}

// ImpactMarketplace CONTRACT: 0x613f857Ad66e1E9983618B28e9c4295B9C1E9E5c
