```typescript
import { NearBindgen, near, call, view, UnorderedMap, assert, NearPromise } from 'near-sdk-js';

// Maps NFT ID to owner address.
const owners = new UnorderedMap<string>("owners");
// Maps owner address to their NFT balance.
const balances = new UnorderedMap<number>("balances");
// Maps NFT ID to approved address.
const tokenApprovals = new UnorderedMap<string>("tokenApprovals");
// Maps owner address to operator approvals.
const operatorApprovals = new UnorderedMap<UnorderedMap<boolean>>("operatorApprovals");

@NearBindgen({})
class MyNFT {
  // Tracks the total supply of NFTs.
  totalSupply: number = 0;

  constructor() {}

  // Allows users to purchase an NFT by sending NEAR to the contract
  @call({ payableFunction: true })
  purchaseNFT(): void {
    // Ensure NEAR is sent with the transaction
    assert(near.attachedDeposit() > BigInt(0), "NEAR value must be greater than 0");

    // Increment the total supply
    this.totalSupply++;

    // Assign the new token ID to the sender
    const tokenId = this.totalSupply;
    const sender = near.predecessorAccountId();
    owners.set(tokenId.toString(), sender);
    let senderBalance = balances.get(sender, { defaultValue: 0 });
    senderBalance++;
    balances.set(sender, senderBalance);

    // Emit the purchase event (not part of ERC-721 but useful for indexing)
    near.log(`EVENT_JSON:{"standard": "nep171", "version": "1.0.0", "event": "nft_mint", "data": [{"owner_id": "${sender}", "token_ids": ["${tokenId}"]}]}`);
  }

  // Allows the owner of an NFT to transfer it to another address
  @call({})
  transferNFT(to: string, tokenId: string): void {
    // Ensure the caller is the owner of the token
    assert(this.ownerOf(tokenId) === near.predecessorAccountId(), "Caller is not the owner");

    // Transfer the token
    this.internalTransfer(near.predecessorAccountId(), to, tokenId);
  }

  // Allows the owner of an NFT to approve another address to transfer the NFT
  @call({})
  approve(to: string, tokenId: string): void {
    // Ensure the caller is the owner of the token
    assert(this.ownerOf(tokenId) === near.predecessorAccountId(), "Caller is not the owner");

    // Approve the address
    tokenApprovals.set(tokenId, to);

    // Emit the approval event (not part of ERC-721 but useful for indexing)
    near.log(`EVENT_JSON:{"standard": "nep171", "version": "1.0.0", "event": "nft_approve", "data": [{"owner_id": "${near.predecessorAccountId()}", "authorized_id": "${to}", "token_ids": ["${tokenId}"]}]}`);
  }

  // Allows the owner of an NFT to revoke an existing approval
  @call({})
  revokeApproval(tokenId: string): void {
    // Ensure the caller is the owner of the token
    assert(this.ownerOf(tokenId) === near.predecessorAccountId(), "Caller is not the owner");

    // Clear the approval
    tokenApprovals.delete(tokenId);

    // Emit the approval revoked event (not part of ERC-721 but useful for indexing)
    near.log(`EVENT_JSON:{"standard": "nep171", "version": "1.0.0", "event": "nft_revoke", "data": [{"owner_id": "${near.predecessorAccountId()}", "token_ids": ["${tokenId}"]}]}`);
  }

  // Returns the total number of NFTs minted
  @view({})
  totalSupply(): number {
    return this.totalSupply;
  }

  // Returns a list of NFT IDs owned by a specific address
  @view({})
  tokensOfOwner(owner: string): string[] {
    const ownerBalance = this.balanceOf(owner);
    const tokens: string[] = [];
    let counter = 0;

    for (let i = 1; i <= this.totalSupply; i++) {
      if (this.ownerOf(i.toString()) === owner) {
        tokens[counter] = i.toString();
        counter++;
      }
    }

    return tokens;
  }

  // Returns the owner of an NFT
  @view({})
  ownerOf(tokenId: string): string {
    // Ensure the token exists
    assert(owners.get(tokenId) !== null, "Token does not exist");
    return owners.get(tokenId) as string;
  }

  // Returns the number of NFTs owned by an account
  @view({})
  balanceOf(owner: string): number {
    return balances.get(owner, { defaultValue: 0 });
  }

  // Internal transfer function
  internalTransfer(from: string, to: string, tokenId: string): void {
    // Ensure the sender is the owner or approved
    assert(
      from === near.predecessorAccountId() ||
      tokenApprovals.get(tokenId) === near.predecessorAccountId(),
      "Unauthorized to transfer"
    );

    // Ensure the token exists
    assert(owners.get(tokenId) !== null, "Token does not exist");

    // Update balances
    let fromBalance = balances.get(from, { defaultValue: 0 });
    fromBalance--;
    balances.set(from, fromBalance);
    let toBalance = balances.get(to, { defaultValue: 0 });
    toBalance++;
    balances.set(to, toBalance);

    // Update owner
    owners.set(tokenId, to);

    // Clear approvals
    tokenApprovals.delete(tokenId);

    // Emit the transfer event (not part of ERC-721 but useful for indexing)
    near.log(`EVENT_JSON:{"standard": "nep171", "version": "1.0.0", "event": "nft_transfer", "data": [{"authorized_id": "${near.predecessorAccountId()}", "old_owner_id": "${from}", "new_owner_id": "${to}", "token_ids": ["${tokenId}"]}]}`);
  }
}
```

**Notes and considerations:**

- The `@openzeppelin` imports in the original contract are not needed in NEAR since the standard library doesn't offer ERC-721 implementation. This functionality is implemented in the contract itself.
- The `Ownable` functionality is not used in this example, but can be added as a separate implementation. In NEAR, it's more common to check for permissions in the methods themselves than relying on separate structs for access. You can add an owner attribute to the contract and check if the caller is the owner before allowing the execution to proceed.
- Instead of `require` and `revert` statements, NEAR uses `assert` which will panic if the condition is false.
- In `purchaseNFT`, `msg.value` is replaced with `near.attachedDeposit()`.
- NEAR smart contracts have an asynchronous nature, for which promises and callbacks are often used. In this example, we are only emitting logs for events (minting, approving, transferring) rather than using promises, but in a production-ready contract this will be necessary. You can learn more about this in the [NFT Marketplace tutorial](https://docs.near.org/tutorials/nfts/marketplace).
- The `override` keyword on the `approve` method is removed since the function doesn't exist natively.
- The `address(0)` in the Solidity contract is replaced with simply deleting the key from the map.
- The `tokensOfOwner` method loops starting from `1` in the Solidity example, because arrays in Solidity start their index at `0`. In the NEAR contract, the for loop starts at `1` because token IDs are generated starting at `1`.
- `ownerOf` and `balanceOf` methods are included in the NEAR contract since the ERC721 contract handles these functions natively.

This is a basic example on how to convert an ERC-721 Solidity contract into a NEAR contract, and there are many other functionalities that could be added, such as royalties, approvals for contracts, and marketplaces.

