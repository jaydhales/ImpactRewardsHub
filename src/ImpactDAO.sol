// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ImpactToken} from "./ImpactDAOToken.sol";
import "./ImpactRewardToken.sol";

interface ISoulNft {
    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function showIds(address _member) external view returns (uint);

    function showMembers() external view returns (address[] memory);
}

contract ImpactDAO {

    uint public id;
    uint votingTime;
    ISoulNft soulnft;
    ImpactToken token;
    ImpactRewardsToken impactrewards;
   
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

    struct DAOTime{
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
    

    mapping(uint => ImpactRewardee) impactrewardee;
    mapping(uint => DAOTime) public daotime;
    mapping(address => uint) memberVotes;
    mapping(address => mapping(uint => bool)) public hasVoted;

    error AlreadyVoted();
    error VotingTimeElapsed();
    error NotDAOMember();
    error OnlyAdmin();
    error NotYetTime();

    event CreateImpact(id, _title, _noOfImpacts, _location, _description, _imageUrl);
    event Vote(address member, _id);

    constructor (address _address, address _ImpactDAOToken, address _ImpactRewardToken) public {
        admin = _address;
        soulnft = ISoulNft(_ImpactDAOToken);
        impactrewards = ImpactRewardsToken(_ImpactRewardToken);
        votingTime = 1 days;
    }

    function createImpact(string memory _title, uint _noOfImpacts, string memory _location, string memory _description, string memory _imageUrl) public returns (uint _id) {
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

        emit CreateImpact(id, _title, _noOfImpacts, _location, _description, _imageUrl);
    }

    function vote(uint _id, Votes votes) external {
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        ImpactRewardee storage impact = impactrewardee[_id];
        if(hasVoted[msg.sender][_id] != false) revert AlreadyVoted();
        if (block.timestamp > daotime[_id].daovotetime) revert VotingTimeElapsed();
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

        function calculateReward(uint _ID) public {
      ImpactRewardee storage impact = impactrewardee[_ID];  
      require(impact.noOfImpacts > 50, "Impacts have to be greater than 50 to get rewarded");
      uint reward = impact.noOfImpacts / 5;
    }

    function approveImpact(uint _id) external {
        ImpactRewardee storage impact = impactrewardee[_id];
        if(impact.yayvotes > impact.nayvotes) {
            // impactrewards.Impact(_ID, _title, _description, _location);
        }
    }
}