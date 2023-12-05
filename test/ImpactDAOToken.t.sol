// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";
import {ImpactDAOToken} from "../src/ImpactDAOToken.sol";
import {ImpactDAO} from "../src/ImpactDAO.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract WildLifeGaurdianTest is Test {
    using stdJson for string;
    ImpactDAOToken Token;
    ImpactDAO Dao;
    bytes32 rootHash =
        0xf5e962c32ca2151bca3e1a2252d8bc3e66b10e01b151dbec10c9ed2f8f095a77;

    address owner = makeAddr("owner");
    address test1 = makeAddr("test1");
    address test2 = makeAddr("test2");
    address test3 = makeAddr("test3");
    address test4 = makeAddr("test4");
    address test5 = makeAddr("test5");

    // airdrop recievers
    address reciever1 = 0x001Daa61Eaa241A8D89607194FC3b1184dcB9B4C;
    address reciever2 = 0x005FbBABD1e619324011d3312CF6166921A294aF;

    address[] members = [owner, test1, test2, test3, test4, test5];

    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    Result r;

    function setUp() public {
        Token = new ImpactDAOToken(owner, "tokenUri_");

        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/Merkle_Airdrop/scripts/gen_files/merkle_tree.json"
        );
        string memory json = vm.readFile(path);
        bytes memory executionResult = json.parseRaw(
            string.concat(".", vm.toString(reciever1))
        );
        r = abi.decode(executionResult, (Result));
    }

    function testSafeMint() public {
        vm.startPrank(owner);
        Token.safeMint(members);

        assertEq(IERC721(address(Token)).balanceOf(owner), 1);
        assertEq(IERC721(address(Token)).balanceOf(test1), 1);
        assertEq(IERC721(address(Token)).balanceOf(test2), 1);
        assertEq(IERC721(address(Token)).balanceOf(test3), 1);
        assertEq(IERC721(address(Token)).balanceOf(test4), 1);
        assertEq(IERC721(address(Token)).balanceOf(test5), 1);

        vm.stopPrank();
    }

    function testSafeMintFailIfNotOwner() public {
        vm.startPrank(test1);

        vm.expectRevert();
        Token.safeMint(members);
    }

    function testSafeMintIfAlreadyOwnsNft() public {
        vm.startPrank(owner);

        Token.safeMint(members);
        assertEq(IERC721(address(Token)).balanceOf(owner), 1);
        assertEq(IERC721(address(Token)).balanceOf(test1), 1);
        assertEq(IERC721(address(Token)).balanceOf(test2), 1);
        vm.stopPrank();

        vm.startPrank(owner);
        Token.safeMint(members);
        assertEq(IERC721(address(Token)).balanceOf(owner), 1);
        assertEq(IERC721(address(Token)).balanceOf(test1), 1);
        assertEq(IERC721(address(Token)).balanceOf(test2), 1);
    }

    function testAddRootHash() public {
        vm.startPrank(owner);
        Token.addRootHash(keccak256(abi.encode("_rootHash")));
    }

    function testClaimToken() public {
        vm.prank(owner);
        Token.addRootHash(rootHash);

        vm.prank(reciever1);
        Token.claimToken(r.proof, reciever1);

        assertEq(IERC721(address(Token)).balanceOf(reciever1), 1);
    }

    function testCantClaimTwice() public {
        vm.prank(owner);
        Token.addRootHash(rootHash);

        vm.startPrank(reciever1);
        Token.claimToken(r.proof, reciever1);
        vm.expectRevert("You already own an nft");
        Token.claimToken(r.proof, reciever1);
    }

    function testCantClaimWithWrongProof() public {
        vm.prank(owner);
        Token.addRootHash(rootHash);

        vm.prank(reciever1);
        bytes32[] memory proof;
        vm.expectRevert(ImpactDAOToken.NotWhitelisted.selector);
        Token.claimToken(proof, reciever1);
    }

    function testTransferFail() public {
        vm.startPrank(owner);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        Token.approve(test2, 1);
        vm.stopPrank();

        vm.startPrank(test2);
        vm.expectRevert("SoulBoundToken: transfer is disabled");
        Token.transferFrom(test1, test2, 1);
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(owner);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(address(Dao));
        Token.burn(2);
        vm.stopPrank();

        assertEq(IERC721(address(Token)).balanceOf(test2), 0);
    }
}
