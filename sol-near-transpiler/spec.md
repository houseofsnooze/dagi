# User story

Users can purchase, transfer, and revoke approvals for NFTs. They can also view the total supply of NFTs and the ones they specifically own. The contract adheres to the ERC-721 standard.

# Technical Specification

## State Variables

- mapping(uint256 => address) private _owners; - Maps NFT ID to owner address.
- mapping(address => uint256) private _balances; - Maps owner address to their NFT balance.
- mapping(uint256 => address) private _tokenApprovals; - Maps NFT ID to approved address.
- mapping(address => mapping(address => bool)) private _operatorApprovals; - Maps owner address to operator approvals.
- uint256 private _totalSupply; - Tracks the total supply of NFTs.

## Functions

### 1. purchaseNFT

Goal

Allows users to purchase an NFT by sending Ether to the contract.

Solidity signature

```solidity
function purchaseNFT() external payable;

State accesses

    Writes to _owners
    Writes to _balances
    Increments _totalSupply

External contract accesses

    None

User scenarios

    Nominal case: User calls purchaseNFT() and sends the required Ether. The contract mints a new NFT, assigns it to the user, and increments the total supply.
    Abnormal case: User calls purchaseNFT() without sending Ether. The transaction should revert.

2. transferNFT

Goal

Allows the owner of an NFT to transfer it to another address.

Solidity signature

function transferNFT(address to, uint256 tokenId) external;

State accesses

    Reads from _owners
    Writes to _owners
    Updates _balances

External contract accesses

    None

User scenarios

    Nominal case: Owner calls transferNFT(address to, uint256 tokenId). The contract checks ownership and transfers the NFT to the new address.
    Abnormal case: Non-owner calls transferNFT(address to, uint256 tokenId). The transaction should revert.

3. approve

Goal

Allows the owner of an NFT to approve another address to transfer the NFT.

Solidity signature

function approve(address to, uint256 tokenId) external;

State accesses

    Writes to _tokenApprovals

External contract accesses

    None

User scenarios

    Nominal case: Owner calls approve(address to, uint256 tokenId). The contract sets the approved address for the NFT.
    Abnormal case: Non-owner calls approve(address to, uint256 tokenId). The transaction should revert.

4. revokeApproval

Goal

Allows the owner of an NFT to revoke an existing approval.

Solidity signature

function revokeApproval(uint256 tokenId) external;

State accesses

    Writes to _tokenApprovals

External contract accesses

    None

User scenarios

    Nominal case: Owner calls revokeApproval(uint256 tokenId). The contract clears the approved address for the NFT.
    Abnormal case: Non-owner calls revokeApproval(uint256 tokenId). The transaction should revert.

5. totalSupply

Goal

Returns the total number of NFTs minted.

Solidity signature

function totalSupply() external view returns (uint256);

State accesses

    Reads _totalSupply

External contract accesses

    None

User scenarios

    Nominal case: User calls totalSupply(). The contract returns the total number of NFTs minted.

6. tokensOfOwner

Goal

Returns a list of NFT IDs owned by a specific address.

Solidity signature

function tokensOfOwner(address owner) external view returns (uint256[] memory);

State accesses

    Reads _owners

External contract accesses

    None

User scenarios

    Nominal case: User calls tokensOfOwner(address owner). The contract returns a list of NFT IDs owned by the specified address.
