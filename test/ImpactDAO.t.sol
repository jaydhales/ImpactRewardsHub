// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "../src/ImpactDAO.sol";
import "../src/ImpactDAOToken.sol";
import "../src/ImpactRewardToken.sol";

contract DAOTest is Test {
    ImpactDAO impactDao;
    ImpactDAO.Votes vote_;
    ImpactDAOToken Token;
    ImpactRewardsToken rewardee;

    address _userA = makeAddr("userA");
    address _userB = makeAddr("userB");
    address _userC = makeAddr("userC");
    address _userD = makeAddr("userD");

    uint256 _privKeyAd;

    uint256 _privKeyA;
    uint256 _privKeyB;
    uint256 _privKeyC;
    uint256 _privKeyD;
    address Admin = makeAddr("ADMIN");
    address test1 = makeAddr("test1");
    address test2 = makeAddr("test2");
    address test3 = makeAddr("test3");
    address test4 = makeAddr("test4");
    address test5 = makeAddr("test5");

    address[] members = [test1, test2, test3, test4];

    function setUp() public {
        Token = new ImpactDAOToken(Admin, "token Uri");
        rewardee = new ImpactRewardsToken();
        impactDao = new ImpactDAO(Admin, address(Token), address(rewardee));
    }

    function testCreateGofundme() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
    }

    function testOnlyAdmin() public {
        vm.startPrank(_userA);
        vm.expectRevert(ImpactDAO.OnlyAdmin.selector);
        impactDao.removeMember();
    }

    function testNotYetTime() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        vm.expectRevert(ImpactDAO.NotYetTime.selector);
        impactDao.removeMember();
    }

    function testCannotRemove() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        vm.startPrank(Admin);
        // Token.safeMint(members);
        vm.warp(3245678900);
        vm.expectRevert("cannot remove");
        impactDao.removeMember();
        vm.stopPrank();
    }

    function testRemoveMember() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        vm.startPrank(_userB);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.warp(31 days);
        impactDao.removeMember();
        vm.stopPrank();
    }

    function testNotMember() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        // Token.balanceOf(test1);
        vm.startPrank(test1);
        vm.expectRevert(ImpactDAO.NotDAOMember.selector);
        impactDao.vote(1, vote_);
    }

    function testAlreadyVoted() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();
        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.expectRevert(ImpactDAO.AlreadyVoted.selector);
        impactDao.vote(1, vote_);
    }

    function testVotingTimeElapsed() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();
        vm.startPrank(test1);
        vm.warp(2 days);
        vm.expectRevert(ImpactDAO.VotingTimeElapsed.selector);
        impactDao.vote(1, vote_);
    }

    function testVote() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();
        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.stopPrank();
        vm.startPrank(test2);
        impactDao.vote(1, vote_);
        vm.stopPrank();
        vm.startPrank(test3);
        impactDao.vote(1, vote_);
        vm.stopPrank();
        vm.startPrank(test4);
        impactDao.vote(1, vote_);
        vm.stopPrank();
    }

    function testNonMemberApproval() public {
        vm.prank(_userB);
        vm.expectRevert(ImpactDAO.NotDAOMember.selector);
        impactDao.approveImpact(1);
    }

    function testVotingInProgress() public {
        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(test1);
        vm.expectRevert(ImpactDAO.VotingInProgress.selector);
        impactDao.approveImpact(1);
    }

    function testApproveProposal() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 20, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.startPrank(test2);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.startPrank(test3);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.startPrank(test4);
        vm.warp(2 days);
        impactDao.approveImpact(1);
    }

    function testRewardImpact() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 60, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.warp(2 days);

        vm.startPrank(test1);
        impactDao.approveImpact(1);
        vm.stopPrank();

        vm.startPrank(_userA);
        impactDao.rewardImpact(1);
        vm.stopPrank();

        assertEq(rewardee.balanceOf(_userA), 12);
    }

    function testRewardImpactFailIfNotApproved() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 60, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.expectRevert("DAO Members has to approve");
        vm.startPrank(_userA);
        impactDao.rewardImpact(1);
        vm.stopPrank();
    }

    function testRewardImpactFailIfNoOfImpactsTooSmall() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 50, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.warp(2 days);

        vm.startPrank(test1);
        impactDao.approveImpact(1);
        vm.stopPrank();

        vm.expectRevert("Impacts have to be greater than 50 to get rewarded");
        vm.startPrank(_userA);
        impactDao.rewardImpact(1);
        vm.stopPrank();
    }

    function testRewardImpactFailIfNotOwner() public {
        vm.startPrank(_userA);
        impactDao.createImpact("jjj", 60, "Nigeria", "planted trees", "http");
        vm.stopPrank();

        vm.startPrank(Admin);
        Token.safeMint(members);
        vm.stopPrank();

        vm.startPrank(test1);
        impactDao.vote(1, vote_);
        vm.stopPrank();

        vm.warp(2 days);

        vm.startPrank(test1);
        impactDao.approveImpact(1);
        vm.stopPrank();

        vm.expectRevert("Only owner can claim  reward");
        vm.startPrank(_userB);
        impactDao.rewardImpact(1);
        vm.stopPrank();
    }
}
