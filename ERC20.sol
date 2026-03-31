// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PointZ2 is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, Ownable {

    /**
     * @notice Deploys the PointZ token.
     * @dev Mints the entire supply to initialOwner at deployment.
     *      No additional minting is possible after deployment.
     * @param initialOwner Address that receives the full supply and admin rights.
     */
    constructor(address initialOwner)
        ERC20("PointZ", "PTZ")
        ERC20Permit("PointZ")
        Ownable(initialOwner)
    {
        _mint(initialOwner, 2_099_999_997_690_000);
    }

    /**
     * @notice Returns the number of decimals used for token amounts.
     * @dev Overrides the ERC20 default of 18.
     */
    function decimals() public pure override returns (uint8) {
        return 8;
    }

    /**
     * @notice Pauses all token transfers.
     * @dev Can only be called by the contract owner
    */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Resumes all token transfers after a pause.
     * @dev Can only be called by the contract owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Transfers tokens to multiple recipients in a single transaction.
     */
    function bulkTransfer(address[] calldata recipients, uint256[] calldata amounts) public {
        require(recipients.length == amounts.length, "PointZ: length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    /**
     * @notice Internal hook called on every transfer, mint, and burn.
     * @dev Required override to reconcile ERC20 and ERC20Pausable.
     *      ERC20Pausable uses this hook to block transfers when paused.
     *      Calls super._update() which chains both parent implementations.
     */
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
