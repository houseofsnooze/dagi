// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC-721 NFT Contract
/// @notice This contract allows users to purchase, transfer, and manage approvals for NFTs. It also provides functions to view the total supply and owned NFTs.
contract MyNFT is ERC721, Ownable {
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Total supply of NFTs
    uint256 private _totalSupply;

    // Event emitted when a new NFT is purchased
    event NFTPurchased(address indexed buyer, uint256 indexed tokenId);

    // Event emitted when an NFT is transferred
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // Event emitted when an approval is given
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // Event emitted when an approval is revoked
    event ApprovalRevoked(address indexed owner, uint256 indexed tokenId);

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    /// @notice Allows users to purchase an NFT by sending Ether to the contract
    function purchaseNFT() external payable {
        // Ensure Ether is sent with the transaction
        require(msg.value > 0, "Ether value must be greater than 0");

        // Increment the total supply
        _totalSupply += 1;

        // Assign the new token ID to the sender
        uint256 tokenId = _totalSupply;
        _owners[tokenId] = msg.sender;
        _balances[msg.sender] += 1;

        // Mint the new token
        _mint(msg.sender, tokenId);

        // Emit the purchase event
        emit NFTPurchased(msg.sender, tokenId);
    }

    /// @notice Allows the owner of an NFT to transfer it to another address
    /// @param to The address to transfer the NFT to
    /// @param tokenId The ID of the NFT to transfer
    function transferNFT(address to, uint256 tokenId) external {
        // Ensure the caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        // Transfer the token
        _transfer(msg.sender, to, tokenId);
    }

    /// @notice Allows the owner of an NFT to approve another address to transfer the NFT
    /// @param to The address to approve
    /// @param tokenId The ID of the NFT to approve
    function approve(address to, uint256 tokenId) external override {
        // Ensure the caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        // Approve the address
        _approve(to, tokenId);
    }

    /// @notice Allows the owner of an NFT to revoke an existing approval
    /// @param tokenId The ID of the NFT to revoke approval for
    function revokeApproval(uint256 tokenId) external {
        // Ensure the caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        // Clear the approval
        _approve(address(0), tokenId);

        // Emit the approval revoked event
        emit ApprovalRevoked(msg.sender, tokenId);
    }

    /// @notice Returns the total number of NFTs minted
    /// @return The total supply of NFTs
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Returns a list of NFT IDs owned by a specific address
    /// @param owner The address to query
    /// @return A list of NFT IDs owned by the specified address
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);
        uint256 counter = 0;

        for (uint256 i = 1; i <= _totalSupply; i++) {
            if (ownerOf(i) == owner) {
                tokens[counter] = i;
                counter++;
            }
        }

        return tokens;
    }
}
