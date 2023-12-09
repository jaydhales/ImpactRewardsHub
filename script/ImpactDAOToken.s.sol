// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ImpactDAOToken.sol";

contract ImpactDAOTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ImpactDAOToken Token = new ImpactDAOToken(
            0xA003A9A2E305Ff215F29fC0b7b4E2bb5a8C2F3e1,
            "ipfs://QmfToDCX5to1KqEuKJczvqFQ8qwe4XniN5qT3vcsUbVP9M"
        );

        vm.stopBroadcast();
    }
}

// ADMIN: 0xA003A9A2E305Ff215F29fC0b7b4E2bb5a8C2F3e1
// ImpactDAOToken CONTRACT: 0x7cD28B73D8AFe3219D742178f2660eC3D018A5E4
