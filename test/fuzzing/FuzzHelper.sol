// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzSetup} from "./FuzzSetup.sol";

/**
 * @title FuzzHelper
 * @author Rappie <rappie@perimetersec.io>
 * @notice Contract containing helper functions
 */
contract FuzzHelper is FuzzSetup {
    /**
     * @notice Helper function to get the sum of all WOETH balances
     * @return sum Sum of all WOETH balances
     */
    function getWOETHBalanceSum() internal view returns (uint256 sum) {
        for (uint256 i = 0; i < ACTORS.length; i++) {
            sum += woeth.balanceOf(ACTORS[i]);
        }
    }

    /**
     * @notice Helper function to get the sum of all WOETH balances including the dead address
     * @return sum Sum of all WOETH balances including the dead address
     */
    function getWOETHBalanceSumInclDead() internal view returns (uint256 sum) {
        sum = getWOETHBalanceSum() + woeth.balanceOf(DEAD_ADDRESS);
    }

    /**
     * @notice Helper function to get the sum of all redeem previews
     * @return sum Sum of all redeem previews
     */
    function getRedeemPreviewSum() internal view returns (uint256 sum) {
        for (uint256 i = 0; i < ACTORS.length; i++) {
            sum += woeth.previewRedeem(woeth.balanceOf(ACTORS[i]));
        }
    }

    /**
     * @notice Helper function to get the sum of all redeem previews including the dead address
     * @return sum Sum of all redeem previews including the dead address
     */
    function getRedeemPreviewSumInclDead() internal view returns (uint256 sum) {
        sum = getRedeemPreviewSum() + woeth.previewRedeem(woeth.balanceOf(DEAD_ADDRESS));
    }
}
