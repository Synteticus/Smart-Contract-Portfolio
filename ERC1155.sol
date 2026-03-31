// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UrbanRealtyFundI is
    ERC1155,
    ERC1155Burnable,
    ERC1155Pausable,
    ERC1155Supply,
    Ownable
{
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

    event BaseURIUpdated(string newBaseURI);
    event TokenURIOverrideSet(uint256 indexed tokenId, string tokenURI);
    event AssetMinted(uint256 indexed tokenId, address indexed to, uint256 amount);
    event SharesMinted(uint256 indexed tokenId, address indexed to, uint256 amount);

    constructor(address initialOwner)
        ERC1155("")
        Ownable(initialOwner)
    {
        _baseTokenURI =
            "ipfs://bafybeibyyhf74whbd3gggnsx6gzymqwuw3q222yloworh4l3i2tqokqi5i/";

        _mint(initialOwner, DEED_BUILDING_1,            1, "");
        _mint(initialOwner, DEED_BUILDING_2,            1, "");
        _mint(initialOwner, DEED_BUILDING_3,            1, "");
        _mint(initialOwner, RENOVATION_CERT_BUILDING_1, 1, "");
        _mint(initialOwner, FUND_SHARE, 300, "");
    }

    // Returns the metadata URI for a given token ID.
    // If a per-token override is set, it takes priority over the base URI.
    // Otherwise the URI is built as: baseTokenURI + tokenId + ".json"
    function uri(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(exists(tokenId), "URI: nonexistent token");

        string memory override_ = _tokenURIOverride[tokenId];
        if (bytes(override_).length > 0) {
            return override_;
        }
        return string(
            abi.encodePacked(_baseTokenURI, tokenId.toString(), ".json")
        );
    }

    // Replaces the base IPFS URI for all tokens at once.
    // Use this after uploading a new metadata folder to Pinata —
    // IPFS folders are immutable, so any change produces a new CID.
    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }

    // Sets or updates the metadata URI for a single token ID.
    // Use this to update one asset without affecting the others.
    // Passing an empty string "" removes the override and falls back to baseURI.
    function setTokenURI(uint256 tokenId, string calldata tokenURI)
        external
        onlyOwner
    {
        _tokenURIOverride[tokenId] = tokenURI;
        emit TokenURIOverrideSet(tokenId, tokenURI);
    }

    // Mints a brand-new asset token (deed or certificate) after deploy.
    // Reverts if the token ID already exists, preventing duplicate deeds.
    // The caller must upload the corresponding metadata to IPFS first
    // and either update the base URI or pass the new token URI directly.
    function mintAsset(
        address to,
        uint256 tokenId,
        uint256 amount,
        string calldata tokenURI
    ) external onlyOwner {
        require(!exists(tokenId), "mintAsset: token already exists");
        if (bytes(tokenURI).length > 0) {
            _tokenURIOverride[tokenId] = tokenURI;
        }
        _mint(to, tokenId, amount, "");
        emit AssetMinted(tokenId, to, amount);
    }

    // Issues additional fund shares (token #4) to a given address.
    // Warning: increases total supply and dilutes all existing holders.
    // In production this should be gated behind a governance vote.
    function mintShares(address to, uint256 amount) external onlyOwner {
        _mint(to, FUND_SHARE, amount, "");
        emit SharesMinted(FUND_SHARE, to, amount);
    }

    // Pauses all token transfers, mints and burns across the contract.
    // Use as an emergency stop in case of exploit or legal requirement.
    function pause()   external onlyOwner { _pause(); }

    // Resumes normal operations after a pause.
    function unpause() external onlyOwner { _unpause(); }

    // Returns the total supply of every token from ID 0 to maxId.
    // Convenience function for frontends that need a full supply snapshot.
    function allSupplies(uint256 maxId)
        external
        view
        returns (uint256[] memory supplies)
    {
        supplies = new uint256[](maxId + 1);
        for (uint256 i = 0; i <= maxId; i++) {
            supplies[i] = totalSupply(i);
        }
    }

    // Required by Solidity when multiple parent contracts define _update().
    // Ensures supply tracking and pause checks both run on every transfer.
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
