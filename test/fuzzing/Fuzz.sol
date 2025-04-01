// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzSetup} from "./FuzzSetup.sol";
import {FuzzWOETHOverTime} from "./FuzzWOETHOverTime.sol";
import {FuzzIntegrity} from "./FuzzIntegrity.sol";

/**
 * @title Fuzz
 * @author Rappie <rappie@perimetersec.io>
 * @notice Composite contract for all of the handlers
 */
contract Fuzz is FuzzWOETHOverTime, FuzzIntegrity {
    constructor() payable FuzzSetup() {}
}
