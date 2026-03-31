// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title Property — Urban Blocks NFT Collection
/// @notice ERC721 contract for the Urban Blocks Collection. Each token represents
///         a unique architectural asset with on-chain metadata stored on IPFS.
///         Developed as part of the MastreZ Web3 Tech Manager portfolio.
/// @dev Extends OpenZeppelin ERC721 with Enumerable, URIStorage, Pausable, Burnable, and Ownable.
contract Property is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, ERC721Burnable {

    /// @notice Maximum number of tokens that can ever be minted.
    uint256 public constant MAX_SUPPLY = 3;

    /// @dev Internal counter to track the next token ID to be minted.
    ///      Starts at 1 so that token IDs map directly to metadata files (1.json, 2.json, 3.json).
    uint256 private _nextTokenId = 1;

    /// @notice Deploys the contract and sets the initial owner.
    /// @param initialOwner The wallet address that will own the contract and have minting rights.
    constructor(address initialOwner)
        ERC721("Property", "RENT")
        Ownable(initialOwner)
    {}

    /// @notice Returns the base URI for all token metadata.
    /// @dev The full tokenURI is built by concatenating _baseURI() + tokenId + ".json".
    ///      Metadata and images are stored on IPFS via Pinata.
    /// @return The IPFS base URI pointing to the metadata folder.
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeicre6rfzve3iycgh3cf36p7orjrc6p5hkyedvnjnmts3ocxblujiu/";
    }

    /// @notice Pauses all token transfers.
    /// @dev Can only be called by the contract owner. Useful as an emergency circuit breaker.
    function pause() public onlyOwner {
        _pause();
    }

    /// @notice Unpauses all token transfers.
    /// @dev Can only be called by the contract owner. Resumes normal contract operation.
    function unpause() public onlyOwner {
        _unpause();
    }

    /// @notice Mints a new token to the specified address.
    /// @dev Only the contract owner can mint. Reverts if MAX_SUPPLY has been reached.
    ///      The token URI is automatically constructed as "<tokenId>.json".
    /// @param to The recipient address that will receive the newly minted NFT.
    /// @return tokenId The ID of the newly minted token.
    function safeMint(address to) public onlyOwner returns (uint256) {
        require(_nextTokenId <= MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(Strings.toString(tokenId), ".json")));
        return tokenId;
    }

    // ─── Required overrides ───────────────────────────────────────────────────

    /// @dev Internal hook called on every token transfer, mint, and burn.
    ///      Required to resolve the conflict between ERC721, ERC721Enumerable, and ERC721Pausable.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /// @dev Internal hook called when a wallet's token balance increases.
    ///      Required to reconcile ERC721 and ERC721Enumerable overrides.
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    /// @notice Returns the metadata URI for a given token.
    /// @dev Resolves the override conflict between ERC721 and ERC721URIStorage.
    /// @param tokenId The ID of the token to query.
    /// @return The full metadata URI string.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /// @notice Checks whether the contract implements a given interface.
    /// @dev Enables marketplace compatibility via ERC165 introspection.
    /// @param interfaceId The ERC165 interface identifier to check.
    /// @return True if the interface is supported, false otherwise.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
