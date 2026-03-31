# Urban Realty Fund I (URF1) — ERC1155 Multi-Token

![Solidity](https://img.shields.io/badge/Solidity-0.8.20-363636?logo=solidity)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-5.x-4E5EE4?logo=openzeppelin)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Network](https://img.shields.io/badge/Network-Ethereum-627EEA?logo=ethereum)
![Storage](https://img.shields.io/badge/Storage-IPFS-65C2CB?logo=ipfs)

A multi-token ERC1155 contract representing a tokenised real estate investment fund, built with OpenZeppelin Contracts v5.x and deployed on Ethereum. This project was developed as part of the **MastreZ Web3 Tech Manager** portfolio, demonstrating end-to-end RWA (Real World Asset) tokenisation: on-chain contract, IPFS metadata, and SVG artwork generation.

---

## Overview

| Property | Value |
|----------|-------|
| Fund Name | Urban Realty Fund I |
| Token Name | Urban Realty Fund I |
| Symbol | URF1 |
| Token Standard | ERC-1155 |
| Network | Ethereum Mainnet |
| Contract Address | [`0xa24b4409c0bf02c57f1f18f838f321d0f131e961`](https://etherscan.io/address/0xa24b4409c0bf02c57f1f18f838f321d0f131e961) |
| Metadata Storage | IPFS via Pinata |
| Image Format | SVG |

---

## Token Structure

The fund holds three properties at launch. Each asset class is represented by a dedicated token ID within the same contract.

| Token ID | Type | Asset | Supply |
|----------|------|-------|--------|
| #0 | NFT | Deed of Ownership — Building I (Modern Tower) | 1 |
| #1 | NFT | Deed of Ownership — Building II (Historic Palazzo) | 1 |
| #2 | NFT | Deed of Ownership — Building III (Industrial Loft) | 1 |
| #3 | NFT | Renovation Certificate — Building I | 1 |
| #4 | FT  | Fund Share | 300 |

**Deed NFTs (tokens 0–2)** represent the on-chain title to each property. Supply is permanently 1, making each one unique. **Renovation certificates (token 3)** document specific capital works linked to a deed via metadata attributes. **Fund shares (token 4)** are fungible tokens representing fractional ownership of the entire portfolio — each share equals 1/300 (≈ 0.33%) of the fund's NAV and carries proportional governance voting rights, delegable to any address.

---

## Features

- **Multi-Token** — A single contract manages both NFTs (deeds, certificates, supply = 1) and FTs (fund shares, supply = 300) simultaneously using ERC-1155, eliminating the need for separate ERC-721 and ERC-20 deployments.
- **Burnable** — Any token holder can permanently destroy their own tokens, reducing circulating supply.
- **Pausable** — The contract owner can pause all transfers in a security emergency. This privilege can be permanently revoked after `renounceOwnership()`.
- **Supply Tracking** — `totalSupply(id)` and `exists(id)` are available on-chain for every token ID via ERC1155Supply.
- **Updatable URI** — The owner can update the global base URI (`setBaseURI`) after uploading a new metadata folder to IPFS, or override a single token's URI (`setTokenURI`) without affecting others.
- **Extensible** — New asset tokens (deeds, certificates) can be added post-deploy via `mintAsset()`. Additional fund shares can be issued via `mintShares()`.
- **Ownable** — All administrative functions are restricted to the contract owner via `onlyOwner`.

---

## Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UrbanRealtyFundI is ERC1155, ERC1155Burnable, ERC1155Pausable, ERC1155Supply, Ownable {
    using Strings for uint256;

    string public name   = "Urban Realty Fund I";
    string public symbol = "URF1";

    uint256 public constant DEED_BUILDING_1            = 0;
    uint256 public constant DEED_BUILDING_2            = 1;
    uint256 public constant DEED_BUILDING_3            = 2;
    uint256 public constant RENOVATION_CERT_BUILDING_1 = 3;
    uint256 public constant FUND_SHARE                 = 4;

    string private _baseTokenURI;
    mapping(uint256 => string) private _tokenURIOverride;

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {
        _baseTokenURI = "ipfs://bafybeibyyhf74whbd3gggnsx6gzymqwuw3q222yloworh4l3i2tqokqi5i/";
        _mint(initialOwner, DEED_BUILDING_1,            1,   "");
        _mint(initialOwner, DEED_BUILDING_2,            1,   "");
        _mint(initialOwner, DEED_BUILDING_3,            1,   "");
        _mint(initialOwner, RENOVATION_CERT_BUILDING_1, 1,   "");
        _mint(initialOwner, FUND_SHARE,                 300, "");
    }

    // Full source including uri(), setBaseURI(), setTokenURI(),
    // mintAsset(), mintShares(), pause(), unpause(), allSupplies()
    // and _update() override — see UrbanRealtyFundI.sol
}
```

---

## IPFS Structure

```
📁 images/     (bafybeic4n46jprrfmsbs2g3y3buhtd3a2fy3a5mxxplweicmqywonuzlky)
   ├── building1.svg
   ├── building2.svg
   ├── building3.svg
   ├── renovation_cert.svg
   └── fund_share.svg

📁 metadata/   (bafybeibyyhf74whbd3gggnsx6gzymqwuw3q222yloworh4l3i2tqokqi5i)
   ├── 0.json
   ├── 1.json
   ├── 2.json
   ├── 3.json
   └── 4.json
```

Each metadata file follows the OpenSea ERC-1155 standard:

```json
{
  "name": "Fund Share",
  "description": "Fungible token representing 1/300 ownership of Urban Realty Fund I.",
  "image": "ipfs://bafybeic4n46.../fund_share.svg",
  "attributes": [
    { "trait_type": "Token Type",        "value": "Fund Share"          },
    { "trait_type": "Fund",              "value": "Urban Realty Fund I" },
    { "trait_type": "Ownership / Share", "value": "0.33%"               },
    { "trait_type": "Total Supply",      "value": "300"                 },
    { "trait_type": "Voting Rights",     "value": "Yes — delegable"     }
  ]
}
```

---

## Design Decisions

### Why ERC-1155 instead of ERC-721 + ERC-20?
A real estate fund holds assets of fundamentally different types — unique deeds (NFT behaviour) and interchangeable shares (FT behaviour). Deploying separate ERC-721 and ERC-20 contracts would mean two deployments, two ABIs, and two sets of gas costs. ERC-1155 consolidates everything into a single contract and a single address, which is both cheaper and architecturally cleaner.

### Why one contract for multiple properties?
This is appropriate when assets belong to the same fund and share governance. The fund is the unit of investment — investors hold shares of the fund, not of individual buildings. In a single-asset deployment model, each building would have its own contract; here the fund structure justifies a shared one.

### Why IPFS immutability requires setBaseURI?
IPFS content is addressed by its hash. Adding a new file to an existing folder changes the folder's CID, invalidating all previous references. `setBaseURI` and `setTokenURI` are therefore not optional convenience functions — they are the necessary upgrade path for metadata when the fund acquires new assets.

### Why mintAsset guards against duplicate IDs?
The `require(!exists(tokenId))` check in `mintAsset` enforces the NFT invariant at the contract level. Without it, an owner could accidentally mint a second deed for an already-tokenised property, creating conflicting ownership records on-chain.

### Why mintShares is owner-only without governance?
This is a deliberate prototype simplification. In production, issuing new shares dilutes existing holders and must be approved via a governance vote. The current design exposes this as an explicit limitation in the README and comments — the function is present but marked for governance gating before any mainnet use with external investors.

---


### Add a New Asset Post-Deploy

1. Upload new image to Pinata (single file) → copy image CID
2. Create `N.json` with `"image": "ipfs://<image_CID>"` → upload to Pinata → copy metadata CID
3. Call `mintAsset(ownerAddress, N, 1, "ipfs://<metadata_CID>")` in Remix

A new building has been added in a second transaction 

---

## Security

- Duplicate deed prevention — `mintAsset` reverts if a token ID already exists
- `onlyOwner` modifier protects all administrative functions
- Built on audited OpenZeppelin Contracts v5.x
- Pausable emergency mechanism available before ownership renunciation
- `renounceOwnership()` available to permanently revoke all admin privileges post-deployment

---

## License

MIT
