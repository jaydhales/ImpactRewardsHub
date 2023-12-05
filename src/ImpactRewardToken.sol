// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract ImpactRewardsToken is ERC20{
    address owner;

    constructor() ERC20 ("Impact Reward Token", "IRT") {
        owner = msg.sender;
    }

   function mint(address to, uint amount) external {
     _mint(to, amount);
   }

   function burn(address to, uint amount) external {
    _burn(to, amount);
   }
}