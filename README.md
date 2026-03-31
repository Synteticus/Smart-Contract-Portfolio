# Smart-Contract-Portfolio
Three Solidity contracts deployed on Ethereum Mainnet, developed as part of the MastreZ Web3 Tech Manager program. Each project covers a different token standard and a distinct real-world use case.

Contracts
PointZ (PTZ) — ERC20
Fixed-supply fungible token mirroring Bitcoin's exact hard cap of 20,999,999.9769 units at 8 decimal precision. Implements burn, pause, gasless approvals via EIP-2612 Permit, and a custom bulkTransfer function for batch distribution.
0xb9e9f8de030be4585c65cb4b14af3a3acf1f92b1

Property (RENT) — ERC721
Fixed-supply NFT collection of three architectural assets (Azure Tower, Amber Palazzo, Crimson Forge). SVG artwork and metadata stored on IPFS via Pinata. Implements burn, pause, enumerable on-chain ownership, and per-token URI storage.
0x687e17d400a0e5b7226c4655d3d20f1d08e89986

Urban Realty Fund I (URF1) — ERC1155
Multi-token contract representing a tokenised real estate investment fund. A single contract manages both unique property deeds (NFT, supply = 1) and fungible fund shares (FT, supply = 300) across three assets. Implements burn, pause, on-chain supply tracking, updatable IPFS metadata, and post-deploy asset expansion.
0xa24b4409c0bf02c57f1f18f838f321d0f131e961

Stack
Solidity ^0.8.20–0.8.27 · OpenZeppelin Contracts v5.x · Remix IDE · IPFS via Pinata · Ethereum Mainnet

License
MIT

Author
Matteo Avenali
