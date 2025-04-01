// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**
 * @title FuzzConfig
 * @author Rappie <rappie@perimetersec.io>
 * @notice Contract containing configuration variables for the fuzzing suite.
 */
contract FuzzConfig {
    // Starting OETH balance for all actors
    uint256 internal constant STARTING_BALANCE = 1_000_000_000_000 ether;

    // Amount minted to burn address during deployment
    uint256 internal constant DEAD_AMOUNT = 1e16;
    // Address to use for burn
    address internal constant DEAD_ADDRESS = address(0xDEAD);
}
