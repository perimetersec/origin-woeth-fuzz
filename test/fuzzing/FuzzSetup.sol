// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzBase} from "fuzzlib/FuzzBase.sol";
import {IHevm, vm} from "fuzzlib/IHevm.sol";

import {FuzzActor} from "./FuzzActor.sol";
import {PropertiesDescriptions} from "./PropertiesDescriptions.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {OETH} from "src/token/OETH.sol";
import {WOETH} from "src/token/WOETH.sol";

/**
 * @title FuzzSetup
 * @author Rappie <rappie@perimetersec.io>
 * @notice Setup for the fuzzing suite
 */
contract FuzzSetup is FuzzActor, FuzzBase, PropertiesDescriptions {
    // Error to be thrown when clamping fails (instead of using `require`)
    error ClampError();

    // Global deployment variables
    OETH oeth;
    WOETH woeth;

    constructor() FuzzBase() {
        deploy();
    }

    /**
     * @notice Deployment
     */
    function deploy() internal {
        // Deploy OETH and WOETH
        oeth = new OETH();
        oeth.initialize(address(this), 1e26);
        woeth = new WOETH(ERC20(address(oeth)));
        woeth.initialize();

        // Mint starting WOETH to dead address
        oeth.approve(address(woeth), DEAD_AMOUNT);
        oeth.mint(address(this), DEAD_AMOUNT);
        woeth.deposit(DEAD_AMOUNT, DEAD_ADDRESS);

        // Set up actors
        setupActors();
    }

    /**
     * @notice Set up actors for the fuzzing suite
     */
    function setupActors() internal {
        for (uint256 i = 0; i < ACTORS.length; i++) {
            address actor = ACTORS[i];

            // Approve all OETH to the WOETH contract
            vm.prank(actor);
            oeth.approve(address(woeth), type(uint256).max);

            // Mint starting balance of OETH
            oeth.mint(actor, STARTING_BALANCE);
        }
    }
}
