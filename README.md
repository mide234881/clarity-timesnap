# TimeSnap NFTs
TimeSnap is a time-limited NFT contract that allows creation of digital collectibles with expiration dates.
Each NFT has a specific lifespan, after which it can no longer be transferred or traded.

## Features
- Mint time-limited NFTs with custom expiration dates
- Transfer NFTs only if they haven't expired
- Check NFT expiration status
- View NFT metadata including creation and expiration timestamps
- SIP-009 compliant NFT implementation
- Enhanced security with ownership verification

## Contract Functions
- `mint`: Create new time-limited NFTs (contract owner only)
- `transfer`: Transfer NFTs that haven't expired (token owner only)
- `get-token-info`: Get NFT metadata
- `is-expired`: Check if an NFT has expired
- `get-token-uri`: Get NFT metadata URI (SIP-009)
- `get-last-token-id`: Get last token ID (SIP-009)

## Error Codes
- 101: Token has expired
- 102: Only contract owner can perform this action
- 103: Token doesn't exist
- 104: Sender doesn't own the token
