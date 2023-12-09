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
            0xE5935E7f16Cc910Cf20B6af95BB510BEB272595e,
            0x668062cDb83fdd2871b55d2d43eD539B783E6A67
        );

        vm.stopBroadcast();
    }
}

// ADMIN: 0xA003A9A2E305Ff215F29fC0b7b4E2bb5a8C2F3e1
// ImpactDAO CONTRACT: 0x64Cfe1121c112E1C7a55522CA0183352BC8C56cC
