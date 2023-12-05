// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

/// @title WildLifeGuardianToken - A unique NFT contract for Wildlife Guardians.

contract ImpactToken is ERC721, ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    bytes32 public rootHash;
    string tokenUri;
  

    address[] public members;

    error InvalidAddress(address);
    error AlreadyClaimed();
    error NotWhitelisted();

    /// @dev Mapping to keep track of claimed tokens.

    mapping(address => bool) claimed;
    mapping(address => uint) addressToIds;

    /// @notice Constructor to initialize the contract.
    /// @param _owner The address of the contract owner.
    /// @param _tokenUri The token URI for the new tokens.
    constructor(
        address _owner,
        string memory _tokenUri
    ) ERC721("Impact Token", "ITK") Ownable(_owner) {
        tokenUri = _tokenUri;
    }

    /// @notice Safely mints new tokens and assigns them to specified addresses.
    /// @param to An array of addresses to receive the newly minted tokens.

    function safeMint(address[] calldata to) public onlyOwner {
        string memory URI = tokenUri;
        for (uint i = 0; i < to.length; ++i) {
            if (to[i] == address(0)) {
                revert InvalidAddress(to[i]);
            }
            if (balanceOf(to[i]) == 0) {
                _setTokenURI(_tokenIdCounter, URI);
                _safeMint(to[i], _tokenIdCounter);
                members.push(to[i]);
                addressToIds[to[i]] = _tokenIdCounter;
                _tokenIdCounter++;
            } else {
                continue;
            }
        }
    }

    /// @notice Claims a token for an address using a Merkle proof.
    /// @param _merkleProof The Merkle proof to verify the claim.
    /// @param _account The address claiming the token.
    /// @return true if the claim is successful, false otherwise.

    function claimToken(
        bytes32[] calldata _merkleProof,
        address _account
    ) external returns (bool) {
        require(_account == msg.sender, "Only owner of account can claim");
        require(balanceOf(_account) == 0, "You already own an nft");
        if (claimed[_account]) {
            revert AlreadyClaimed();
        }
        bytes32 leaf = keccak256(abi.encodePacked(_account, uint(1)));
        if (!MerkleProof.verify(_merkleProof, rootHash, leaf)) {
            revert NotWhitelisted();
        }

        claimed[_account] = true;
        _setTokenURI(_tokenIdCounter, tokenUri);
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;

        return true;
    }

    /// @notice Adds a new Merkle root hash for token whitelisting.
    /// @param _rootHash The new Merkle root hash.

    function addRootHash(bytes32 _rootHash) external onlyOwner {
        rootHash = _rootHash;
    }

    /// @notice Burns a token by its ID.
    /// @param tokenId The ID of the token to burn.

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function showIds(address _member) public view returns (uint) {
        return addressToIds[_member];
    }

    function showMembers() external view returns (address[] memory) {
        return members;
    }

    // function overrides

    /// @dev Overrides the transferFrom function to disable transfers.

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        revert("SoulBoundToken: transfer is disabled");
    }

    /// @inheritdoc ERC721

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /// @inheritdoc ERC721

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
