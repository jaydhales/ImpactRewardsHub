// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "../src/ImpactMarketplace.sol";
import "../src/ImpactDAOToken.sol";
import "../src/ImpactRewardToken.sol";

contract ImpactMarketPlaceTest is Test {
    ImpactMarketPlace marketplace;
    ImpactDAOToken Token;
    ImpactRewardsToken rewardee;

    address Admin = makeAddr("ADMIN");

    // members
    address test1 = makeAddr("test1");
    address test2 = makeAddr("test2");
    address test3 = makeAddr("test3");
    address test4 = makeAddr("test4");
    address test5 = makeAddr("test5");

    address[] members = [test1, test2, test3, test4];

    // non member
    address randomUser = makeAddr("random");

    function setUp() public {
        Token = new ImpactDAOToken(Admin, "token Uri");
        rewardee = new ImpactRewardsToken();
        marketplace = new ImpactMarketPlace(address(Token), address(rewardee));
    }

    function testUploadProduct() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        marketplace.uploadProduct(
            "test",
            "test description",
            1 ether,
            "test image",
            3
        );
        vm.stopPrank();
    }

    function testUploadProductFailIfNotDaoMember() public {
        vm.expectRevert(ImpactMarketPlace.NotDAOMember.selector);
        vm.startPrank(test2);
        marketplace.uploadProduct(
            "test",
            "test description",
            1 ether,
            "test image",
            30
        );
        vm.stopPrank();
    }

    function testUploadProductFailIfPriceIsInvalid() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.expectRevert("Product price must be greater than 0");

        vm.startPrank(test1);
        marketplace.uploadProduct(
            "test",
            "test description",
            0,
            "test image",
            3
        );
        vm.stopPrank();
    }

    function testUploadProductFailIfAvailableItemsIsInvalid() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.expectRevert("Product available must be greater than 0");

        vm.startPrank(test1);
        marketplace.uploadProduct(
            "test",
            "test description",
            0.001 ether,
            "test image",
            0
        );
        vm.stopPrank();
    }

    function testEditProduct() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        marketplace.uploadProduct(
            "test",
            "test description",
            0.001 ether,
            "test image",
            3
        );
        marketplace.editProduct(1, 0.002 ether, 5);
        vm.stopPrank();
    }

    function testEditProductFailIfNotDaoMember() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        marketplace.uploadProduct(
            "test",
            "test description",
            0.001 ether,
            "test image",
            3
        );
        vm.expectRevert(ImpactMarketPlace.NotDAOMember.selector);
        vm.startPrank(randomUser);
        marketplace.editProduct(1, 0.002 ether, 5);
        vm.stopPrank();
    }

    function testDeleteProduct() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        marketplace.uploadProduct(
            "test",
            "test description",
            0.001 ether,
            "test image",
            3
        );

        vm.startPrank(test1);
        marketplace.deleteProduct(1);
        vm.stopPrank();
    }

    function testBuyProduct() public {
        testUploadProduct();

        vm.startPrank(test1);
        rewardee.mint(test1, 1e18);
        rewardee.approve(address(marketplace), 10e18);

        marketplace.buyProduct(0, 1);
        vm.stopPrank();

        assertEq(rewardee.balanceOf(test1), 0);
    }

    function testBuyProductFailIfProductNotAvailable() public {
        vm.expectRevert("Product not available");
        vm.startPrank(test1);
        marketplace.buyProduct(0, 1);
        vm.stopPrank();
    }
}
