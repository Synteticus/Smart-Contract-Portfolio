# PointZ (PTZ) — ERC20 Token

![Solidity](https://img.shields.io/badge/Solidity-0.8.27-363636?logo=solidity)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-5.6.0-4E5EE4?logo=openzeppelin)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Network](https://img.shields.io/badge/Network-Ethereum-627EEA?logo=ethereum)

A fixed-supply ERC20 token built with OpenZeppelin Contracts v5.6.0, deployed on Ethereum. This project was developed as part of the **MastreZ Web3 Tech Manager** portfolio, demonstrating best practices in token design, access control, and on-chain security.

---

## Overview

| Property | Value |
|----------|-------|
| Token Name | PointZ |
| Symbol | PTZ |
| Decimals | 8 |
| Max Supply | 20,999,999.9769 PTZ |
| Raw Supply (smallest unit) | 2,099,999,997,690,000 |
| Network | Ethereum Mainnet |
| Contract Address | [`0xb9e9f8de030be4585c65cb4b14af3a3acf1f92b1`](https://etherscan.io/address/0xb9e9f8de030be4585c65cb4b14af3a3acf1f92b1) |

> The supply of 20,999,999.9769 PTZ mirrors Bitcoin's exact theoretical hard cap — the precise amount of BTC that will ever exist due to integer rounding in block subsidy halving over Bitcoin's full emission schedule. The token uses 8 decimal places, matching Bitcoin's satoshi precision, in contrast to the ERC20 standard of 18. This design is also used by WBTC (Wrapped Bitcoin).

---

## Features

- **Fixed Supply** — 20,999,999.9769 tokens minted at deployment to the `initialOwner`. No mint function exists; the supply is immutable from block zero.
- **8 Decimals** — Mirrors Bitcoin's satoshi precision rather than the ERC20 default of 18.
- **Burnable** — Any token holder can permanently destroy their own tokens, reducing circulating supply.
- **Pausable** — The contract owner can pause all transfers in a security emergency. This privilege is permanently revoked after `renounceOwnership()` is called.
- **Permit (EIP-2612)** — Supports gasless approvals via off-chain signatures, improving composability with DeFi protocols.
- **BulkTransfer** — Custom function allowing the sender to distribute tokens to multiple recipients in a single transaction, reducing gas costs.
- **Ownable** — Administrative control is held by the deployer during the testing phase and explicitly renounced post-deployment.

---

## Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PointZ is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, Ownable {

    constructor(address initialOwner)
        ERC20("PointZ", "PTZ")
        ERC20Permit("PointZ")
        Ownable(initialOwner)
    {
        // 20,999,999.9769 PTZ * 10^8 = 2,099,999,997,690,000
        _mint(initialOwner, 2_099_999_997_690_000);
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }

    function pause() public onlyOwner { _pause(); }
    function unpause() public onlyOwner { _unpause(); }

    function bulkTransfer(address[] calldata recipients, uint256[] calldata amounts) public {
        require(recipients.length == amounts.length, "PointZ: length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
```

---

## Design Decisions

### Why 20,999,999.9769 PTZ?
Bitcoin's protocol will never produce a full 21 million BTC. Due to integer rounding in block reward halving across Bitcoin's entire emission schedule, the true hard cap is 20,999,999.9769 BTC. The PTZ supply replicates this exact figure as a deliberate reference to Bitcoin's design.

### Why 8 decimals?
Standard ERC20 tokens use 18 decimal places. PTZ uses 8, matching Bitcoin's satoshi unit. This is the same approach taken by WBTC (Wrapped Bitcoin) and makes the token's smallest unit semantically equivalent to one satoshi. There are no technical issues with overriding decimals in OpenZeppelin — it is a display parameter and does not affect internal token logic.

### Why fixed supply?
Minting all tokens at deployment eliminates inflation risk and removes the need for a privileged mint function. There is no mechanism to increase supply after deployment.

### Why Pausable + renounceOwnership?
The Pausable extension provides an emergency circuit breaker during the initial deployment and testing phase. Once all functions have been verified on-chain, `renounceOwnership()` is called to permanently disable all admin privileges — making the contract fully immutable and trustless.

### Why BulkTransfer?
The standard ERC20 `transfer` function processes one recipient per transaction. The `bulkTransfer` function batches multiple transfers into a single transaction, reducing gas overhead and demonstrating the ability to extend standard token behaviour with custom logic.

### Why ERC20Permit?
Permit (EIP-2612) enables users to approve token spending via a signed message rather than a separate on-chain transaction, reducing gas costs and improving integration with DeFi protocols.


---

## Security

- No public mint function — supply is fixed at deployment
- Ownership explicitly renounced after testing — no admin backdoor remains
- Built on audited OpenZeppelin Contracts v5.6.0

---

## License

MIT
