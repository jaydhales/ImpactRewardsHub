// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";
import {Merkle} from "../contracts/MerkleAirdrop.sol";

contract MerkleTest is Test {
    using stdJson for string;
    Merkle public merkle;
    bytes32 public merkleRoot =
        0xc87618c6c49eb4b0825fe2b7323eb2d0a34647d57571acbc0eed60825db81123;
    address user1 = 0x001Daa61Eaa241A8D89607194FC3b1184dcB9B4C;
    address user2 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address tokenAddress = 0xa5a6af6C7Eb4F39Ac3E247887FdaF86f0E649794;

    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    Result r;

    function setUp() public {
        merkle = new Merkle(merkleRoot);
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/scripts/gen_files/merkle_tree.json"
        );
        string memory json = vm.readFile(path);
        bytes memory executionResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        r = abi.decode(executionResult, (Result));
    }

    function testClaim() public {
        vm.prank(user1);
        bool success = merkle.claimToken(r.proof, user1, 45000000000000);
        assertEq(merkle.balanceOf(user1), 45000000000000);
        assertTrue(success);
    }

    function testCantClaimTwice() public {
        vm.prank(user1);
        merkle.claimToken(r.proof, user1, 45000000000000);
        vm.expectRevert(Merkle.AlreadyClaimed.selector);
        merkle.claimToken(r.proof, user1, 45000000000000);
    }

    function testCantClaimWithWrongProof() public {
        vm.prank(user1);
        bytes32[] memory proof;
        vm.expectRevert(Merkle.NotWhitelisted.selector);
        merkle.claimToken(proof, user1, 45000000000000);
    }

    function testCantClaimWithWrongAmount() public {
        vm.prank(user1);
        vm.expectRevert(Merkle.NotWhitelisted.selector);
        merkle.claimToken(r.proof, user1, 4500000000000122);
    }

    function testCantClaimWithWrongAddress() public {
        vm.prank(user1);
        vm.expectRevert(Merkle.NotWhitelisted.selector);
        merkle.claimToken(r.proof, user2, 45000000000000);
        assertEq(merkle.balanceOf(user2), 0);
    }
}
