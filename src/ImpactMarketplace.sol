// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./ImpactDAO.sol";
import "./ImpactRewardToken.sol";

interface SoulNft {
    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function showIds(address _member) external view returns (uint);

    function showMembers() external view returns (address[] memory);
}
contract ImpactMarketPlace{

    IERC20 private immutable token;
    uint256 private idCounter;
    SoulNft soulnft;
    ImpactRewardsToken impactrewards;
    
    // we can add admin functionalities...
    // I'm thinking it should be onlyadmin that can upload and edit or dao members, you decide.

    event ProductCreated(uint256 id, string name, string description, uint256 price, string image, uint256 sold, uint256 availableItems);
    event ProductUpdated(uint id, uint256 price,  uint256 availableItems);
    event ProductDeleted(uint id);
    event ProductBought(uint id, address buyer, uint256 price, uint quantity);

    error NotDAOMember();

    constructor(address _token, address _ImpactDAOToken, address _ImpactRewardToken){
        token = IERC20( _token);
        soulnft = SoulNft(_ImpactDAOToken);
        impactrewards = ImpactRewardsToken(_ImpactRewardToken);
    }

    struct Product{
        uint256 id;
        string name;
        string description;
        uint256 price;
        uint256 sold;
        string image;
        uint256 availableItems;
    }

    mapping(uint256 => Product) private products;
    function uploadProduct(string memory _name, string memory _description, uint256 _price, string memory _image, uint256 available) external payable{
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        uint256 id = idCounter++;
        require(_price > 0);
        require(available > 0);

        Product storage p = products[id];
        p.id = id;
        p.name = _name;
        p.description = _description;
        p.price = _price;
        p.image = _image;
        p.sold = 0;
        p.availableItems = available;

        emit ProductCreated(id, _name, _description, _price, _image, 0, available);
    }


    function editProduct(uint256 id,uint256 _price, uint256 available) external{
        Product storage p = products[id];
        p.price = _price;
        p.availableItems = available;
    }

    function deleteProduct(uint256 id) external{
        delete products[id];
    }

    function buyProduct(uint256 id, uint256 quantity) external payable{
        require(id <= idCounter, "Invalid Product ID");
        Product storage p = products[id];
        uint quantityPrice = p.price * quantity;
        require(impactrewards.balanceOf(msg.sender) >= quantityPrice, "Not Enough Impact rewards token");
        require(p.availableItems > 0, "Product not available");
        p.sold++;
        p.availableItems--;
        impactrewards.transferFrom(msg.sender, address(this), quantityPrice);
        impactrewards.burn(address(this), quantityPrice);

        emit ProductBought(id, msg.sender, p.price, quantity);
    }

    
}