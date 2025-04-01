// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzConfig} from "./FuzzConfig.sol";

/**
 * @title FuzzActor
 * @author Rappie <rappie@perimetersec.io>
 * @notice Contract containing the actor configuration
 */
contract FuzzActor is FuzzConfig {
    // Actors are the addresses to be used as senders.
    address internal constant ADDRESS_ACTOR1 = address(0x10000);
    address internal constant ADDRESS_ACTOR2 = address(0x20000);
    address internal constant ADDRESS_ACTOR3 = address(0x30000);

    // List of all actors
    address[] internal ACTORS = [ADDRESS_ACTOR1, ADDRESS_ACTOR2, ADDRESS_ACTOR3];

    // Variable containing current actor.
    address internal currentActor;

    // Debug toggle to disable setting the current actor.
    bool internal constant DEBUG_TOGGLE_SET_ACTOR = true;

    /// @notice Modifier storing `msg.sender` for the duration of the function call.
    modifier setCurrentActor() {
        address previousActor = currentActor;
        if (DEBUG_TOGGLE_SET_ACTOR) {
            currentActor = msg.sender;
        }

        _;

        if (DEBUG_TOGGLE_SET_ACTOR) {
            currentActor = previousActor;
        }
    }
}
