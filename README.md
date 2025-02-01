# TimeSnap NFTs
TimeSnap is a time-limited NFT contract that allows creation of digital collectibles with expiration dates.
Each NFT has a specific lifespan, after which it can no longer be transferred or traded.

## Features
- Mint time-limited NFTs with custom expiration dates
- Transfer NFTs only if they haven't expired
- Check NFT expiration status
- View NFT metadata including creation and expiration timestamps

## Contract Functions
- `mint`: Create new time-limited NFTs
- `transfer`: Transfer NFTs that haven't expired
- `get-token-info`: Get NFT metadata
- `is-expired`: Check if an NFT has expired
