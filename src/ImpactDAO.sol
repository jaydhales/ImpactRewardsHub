// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ImpactDAOToken} from "./ImpactDAOToken.sol";
import "./ImpactRewardToken.sol";

interface ISoulNft {
    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function showIds(address _member) external view returns (uint);

    function showMembers() external view returns (address[] memory);
}

struct ImpactRewardee {
    uint id_;
    address owner;
    string title;
    string description;
    string location;
    uint yayvotes;
    uint nayvotes;
    uint noOfImpacts;
    string imageUrl;
}

contract ImpactDAO {
    uint public id;
    uint votingTime;
    uint _time;
    address admin;
    ISoulNft soulnft;
    ImpactDAOToken token;
    ImpactRewardsToken impactrewards;

    struct DAOTime {
        uint daovotetime;
    }

    enum Votes {
        YAY,
        NAY
    }
    enum Status {
        Pending,
        Approved
    }

    Status public status;
    mapping(uint => ImpactRewardee) impactrewardee;
    mapping(uint => DAOTime) public daotime;
    mapping(address => uint) memberVotes;
    mapping(address => mapping(uint => bool)) public hasVoted;

    error AlreadyVoted();
    error VotingTimeElapsed();
    error NotDAOMember();
    error OnlyAdmin();
    error NotYetTime();
    error VotingInProgress();

    event CreateImpact(
        uint _id,
        string _title,
        uint _noOfImpacts,
        string _location,
        string _description,
        string _imageUrl
    );
    event Vote(address member, uint _id);
    event ApproveImpact(uint _id);
    event MemberRemoved(uint id_);
    event RewardImpact(uint _id);

    constructor(
        address _address,
        address _ImpactDAOToken,
        address _ImpactRewardToken
    ) {
        admin = _address;
        soulnft = ISoulNft(_ImpactDAOToken);
        impactrewards = ImpactRewardsToken(_ImpactRewardToken);
        votingTime = 1 days;
    }

    function createImpact(
        string memory _title,
        uint _noOfImpacts,
        string memory _location,
        string memory _description,
        string memory _imageUrl
    ) public returns (uint _id) {
        id++;
        _id = id;
        if (_id == 1) {
            _time = block.timestamp + 30 days;
        }
        ImpactRewardee storage impact = impactrewardee[_id];
        DAOTime storage time = daotime[_id];
        impact.id_ = _id;
        impact.title = _title;
        impact.noOfImpacts = _noOfImpacts;
        impact.location = _location;
        impact.description = _description;
        impact.imageUrl = _imageUrl;
        impact.owner = msg.sender;
        time.daovotetime = votingTime + block.timestamp;
        status = Status.Pending;

        emit CreateImpact(
            _id,
            _title,
            _noOfImpacts,
            _location,
            _description,
            _imageUrl
        );
    }

    function vote(uint _id, Votes votes) external {
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        ImpactRewardee storage impact = impactrewardee[_id];
        if (hasVoted[msg.sender][_id] != false) revert AlreadyVoted();
        if (block.timestamp > daotime[_id].daovotetime)
            revert VotingTimeElapsed();
        hasVoted[msg.sender][_id] = true;

        uint8 numVotes = 1;
        if (votes == Votes.YAY) {
            impact.yayvotes += numVotes;
        } else {
            impact.nayvotes += numVotes;
        }
        memberVotes[msg.sender]++;

        emit Vote(msg.sender, _id);
    }

    function removeMember() external {
        if (msg.sender != admin) revert OnlyAdmin();
        if (_time > block.timestamp) revert NotYetTime();
        _time = block.timestamp + 30 days;

        require(id > 1, "cannot remove");
        uint removeCriteria = (70 * id) / 100;
        address[] memory m = soulnft.showMembers();
        for (uint i = 0; i < m.length; i++) {
            address daoMembers = m[i];

            if (memberVotes[daoMembers] < removeCriteria) {
                uint id_ = soulnft.showIds(daoMembers);
                soulnft.burn(id_);
                emit MemberRemoved(id_);
            }
        }
    }

    function approveImpact(uint _id) external {
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        if (daotime[_id].daovotetime > block.timestamp)
            revert VotingInProgress();
        ImpactRewardee storage impact = impactrewardee[_id];
        if (impact.yayvotes > impact.nayvotes) {
            status = Status.Approved;
        }

        emit ApproveImpact(_id);
    }

    function rewardImpact(uint _ID) external {
        ImpactRewardee storage impact = impactrewardee[_ID];
        require(status == Status.Approved, "DAO Members has to approve");
        require(
            impact.noOfImpacts > 50,
            "Impacts have to be greater than 50 to get rewarded"
        );
        require(msg.sender == impact.owner, "Only owner can claim  reward");
        uint impactreward = impact.noOfImpacts / 5;
        impactrewards.mint(impact.owner, impactreward);
        impactreward = 0;

        emit RewardImpact(_ID);
    }
}
