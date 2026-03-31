# Property (RENT) — ERC721 NFT Collection

![Solidity](https://img.shields.io/badge/Solidity-0.8.27-363636?logo=solidity)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-5.6.0-4E5EE4?logo=openzeppelin)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Network](https://img.shields.io/badge/Network-Ethereum-627EEA?logo=ethereum)
![Storage](https://img.shields.io/badge/Storage-IPFS-65C2CB?logo=ipfs)

A fixed-supply ERC721 NFT collection built with OpenZeppelin Contracts v5.6.0, deployed on Ethereum. This project was developed as part of the **MastreZ Web3 Tech Manager** portfolio, demonstrating end-to-end NFT deployment: on-chain contract, IPFS metadata, and SVG artwork generation.

---

## Overview

| Property | Value |
|----------|-------|
| Collection Name | Urban Blocks |
| Token Name | Property |
| Symbol | RENT |
| Total Supply | 3 NFTs |
| Token Standard | ERC-721 |
| Network | Ethereum Mainnet |
| Contract Address | [`0x687e17d400a0e5b7226c4655d3d20f1d08e89986`](https://etherscan.io/address/0x687e17d400a0e5b7226c4655d3d20f1d08e89986) |
| Metadata Storage | IPFS via Pinata |
| Image Format | SVG |

---

## The Collection

Each token represents a unique architectural asset with distinct on-chain traits. Artwork is generated as SVG and stored on IPFS.

| Token ID | Name | Type | District | Era | Energy Class |
|----------|------|------|----------|-----|--------------|
| #1 | Azure Tower | Commercial | Financial Hub | 2024 | A+ Platinum |
| #2 | Amber Palazzo | Residential | Historic Centre | 1892 | G — Historic |
| #3 | Crimson Forge | Industrial | Docklands | 1964 | D — Industrial |

---

## Features

- **Fixed Supply** — Hard cap of 3 tokens enforced on-chain via `MAX_SUPPLY` constant. The contract reverts with `"Max supply reached"` on any mint attempt beyond the limit.
- **Auto-incrementing Token IDs** — Token IDs start at 1 and increment automatically on each mint, mapping directly to `1.json`, `2.json`, `3.json` on IPFS.
- **IPFS Metadata** — All artwork (SVG) and metadata (JSON) are stored on IPFS via Pinata. The `_baseURI` points to a pinned folder; each `tokenURI` resolves to the full path automatically.
- **Burnable** — Any token holder can permanently destroy their own NFT, reducing circulating supply.
- **Pausable** — The contract owner can pause all transfers in a security emergency. Privilege is revoked after `renounceOwnership()`.
- **Enumerable** — Supports on-chain enumeration of all tokens owned by a wallet, required by most marketplace indexers.
- **URIStorage** — Per-token URI override enabling individual metadata pointers within a shared base path.
- **Ownable** — Minting is restricted to the contract owner via `onlyOwner`. Admin control is renounced post-deployment.

---

## Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract Property is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, ERC721Burnable {

    uint256 public constant MAX_SUPPLY = 3;
    uint256 private _nextTokenId = 1;

    constructor(address initialOwner)
        ERC721("Property", "RENT")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeicre6rfzve3iycgh3cf36p7orjrc6p5hkyedvnjnmts3ocxblujiu/";
    }

    function pause() public onlyOwner { _pause(); }
    function unpause() public onlyOwner { _unpause(); }

    function safeMint(address to) public onlyOwner returns (uint256) {
        require(_nextTokenId <= MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(Strings.toString(tokenId), ".json")));
        return tokenId;
    }

    // Required overrides omitted for brevity — see Property.sol for full source.
}
```

---

## IPFS Structure

```
📁 images/     (bafybeidrcvkqmoe2lfmllmz5a457tkoxflexjep47mj6arxdzhjbz4kide)
   ├── nft_01_azure_tower.svg
   ├── nft_02_amber_palazzo.svg
   └── nft_03_crimson_forge.svg

📁 metadata/   (bafybeicre6rfzve3iycgh3cf36p7orjrc6p5hkyedvnjnmts3ocxblujiu)
   ├── 1.json
   ├── 2.json
   └── 3.json
```

Each metadata file follows the OpenSea standard:

```json
{
  "name": "Azure Tower",
  "description": "A gleaming glass skyscraper rising 42 floors above the Financial Hub. Property Collection x MastreZ portfolio",
  "image": "ipfs://bafybeidrcvkqmoe2lfmllmz5a457tkoxflexjep47mj6arxdzhjbz4kide/nft_01_azure_tower.svg",
  "attributes": [
    { "trait_type": "Type",         "value": "Commercial"    },
    { "trait_type": "Height",       "value": "42 Floors"     },
    { "trait_type": "Era",          "display_type": "number", "value": 2024 },
    { "trait_type": "District",     "value": "Financial Hub" },
    { "trait_type": "Energy Class", "value": "A+ Platinum"   }
  ]
}
```

---

## Design Decisions

### Why MAX_SUPPLY enforced on-chain?
The supply cap is not just a convention — it is enforced by a `require` statement inside `safeMint`. Even the contract owner cannot mint a 4th token. This makes the scarcity guarantee trustless and verifiable by anyone reading the contract.

### Why start tokenId at 1?
Starting at 1 ensures a clean 1-to-1 mapping between token IDs and metadata filenames (`1.json`, `2.json`, `3.json`), avoiding an unreachable `0.json` file on IPFS.

### Why auto-construct the URI in safeMint?
Rather than passing the URI manually on each mint — which is error-prone — the contract builds it programmatically using `Strings.toString(tokenId) + ".json"`. This guarantees consistency and removes human error from the minting flow.

### Why SVG for artwork?
SVG files are vector-based, fully on-chain readable, and rendered natively by all major browsers and NFT marketplaces. They require no external rendering engine and are significantly smaller than raster formats for architectural illustration.

### Why Pausable + renounceOwnership?
The Pausable extension provides an emergency circuit breaker during the initial deployment and testing phase. Once all tokens are verified on-chain, `renounceOwnership()` permanently disables all admin privileges — making the contract trustless.

### Why ERC721Enumerable?
Enumerable enables on-chain queries like "which tokens does this wallet own?", required by most marketplace indexers (OpenSea, Blur, Rarible) for proper portfolio display.

---

## Security

- Hard supply cap enforced on-chain — `MAX_SUPPLY` constant cannot be overridden
- No public mint function — only the contract owner can mint via `safeMint`
- `onlyOwner` modifier protects all administrative functions
- Ownership explicitly renounced after testing — no admin backdoor remains post-launch
- Built on audited OpenZeppelin Contracts v5.6.0
- Pausable emergency mechanism available before ownership renunciation

---

## License

MIT
