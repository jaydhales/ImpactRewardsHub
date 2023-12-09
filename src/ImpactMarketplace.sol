// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ImpactDAO.sol";
import "./ImpactRewardToken.sol";

interface SoulNft {
    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function showIds(address _member) external view returns (uint256);

    function showMembers() external view returns (address[] memory);
}

struct Product {
    uint256 id;
    string name;
    string description;
    uint256 price;
    uint256 sold;
    string image;
    uint256 availableItems;
}

contract ImpactMarketPlace {
    uint256 private idCounter;
    SoulNft soulnft;
    ImpactRewardsToken impactrewards;

    // we can add admin functionalities...
    // I'm thinking it should be onlyadmin that can upload and edit or dao members, you decide.

    event ProductCreated(
        uint256 id, string name, string description, uint256 price, string image, uint256 sold, uint256 availableItems
    );
    event ProductUpdated(uint256 id, uint256 price, uint256 availableItems);
    event ProductDeleted(uint256 id);
    event ProductBought(uint256 id, address buyer, uint256 price, uint256 quantity);
    event ProductEdited(uint256 id, uint256 price, uint256 availableItems);

    error NotDAOMember();

    constructor(address _ImpactDAOToken, address _ImpactRewardToken) {
        soulnft = SoulNft(_ImpactDAOToken);
        impactrewards = ImpactRewardsToken(_ImpactRewardToken);
    }

    mapping(uint256 => Product) private products;

    function uploadProduct(
        string memory _name,
        string memory _description,
        uint256 _price,
        string memory _image,
        uint256 available
    ) external payable {
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        uint256 id = idCounter++;
        require(_price > 0, "Product price must be greater than 0");
        require(available > 0, "Product available must be greater than 0");

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

    function editProduct(uint256 id, uint256 _price, uint256 available) external {
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        Product storage p = products[id];
        p.price = _price;
        p.availableItems = available;

        emit ProductEdited(id, _price, available);
    }

    function deleteProduct(uint256 id) external {
        if (soulnft.balanceOf(msg.sender) != 1) revert NotDAOMember();
        delete products[id];
        emit ProductDeleted(id);
    }

    function buyProduct(uint256 id, uint256 quantity) external payable {
        require(id <= idCounter, "Invalid Product ID");
        Product storage p = products[id];
        uint256 quantityPrice = p.price * quantity;
        require(impactrewards.balanceOf(msg.sender) >= quantityPrice, "Not Enough Impact rewards token");
        require(p.availableItems > 0, "Product not available");
        p.sold++;
        p.availableItems--;
        impactrewards.burn(msg.sender, quantityPrice);

        emit ProductBought(id, msg.sender, p.price, quantity);
    }
}
