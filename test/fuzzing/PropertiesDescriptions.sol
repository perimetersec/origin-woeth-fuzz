// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PropertiesDescriptions
 * @author Rappie <rappie@perimetersec.io>
 * @notice Descriptions strings for the invariants
 */
abstract contract PropertiesDescriptions {
    string internal constant TASSETS_01 =
        "TASSETS-01: Deposits do not affect total assets except for the OETH transferred by the user";
    string internal constant TASSETS_02 =
        "TASSETS-02: Minting does not affect total assets except for the OETH transferred by the user";
    string internal constant TASSETS_03 =
        "TASSETS-03: Withdrawing does not affect total assets except for the OETH transferred by the user";
    string internal constant TASSETS_04 =
        "TASSETS-04: Redeeming does not affect total assets except for the OETH transferred by the user";
    string internal constant TASSETS_05 = "TASSETS-05: Transfering does not affect total assets";
    string internal constant TASSETS_06 = "TASSETS-06: Changing OETH supply does not affect total assets";
    string internal constant TASSETS_07 = "TASSETS-07: Donating does not change total assets";
    string internal constant TASSETS_08 = "TASSETS-08: Scheduling yield does not change total assets";

    string internal constant SOLV_01 = "SOLV-01: All users can fully redeem their wOETH at any time";
    string internal constant SOLV_02 =
        "SOLV-02: Sum of all users' redeem previews equals total assets (within tolerance)";
    string internal constant SOLV_03 = "SOLV-03: Redeem preview strictly increases over time";

    string internal constant YIELD_01 =
        "YIELD-01: All currently undistributed yield is fully distributed at cycle end (within tolerance)";
    string internal constant YIELD_02 =
        "YIELD-02: Exchange rate remains constant within a single block (within tolerance)";
    string internal constant YIELD_03 =
        "YIELD-03: Redeem preview never decreases without interactions with WOETH (within tolerance)";
    string internal constant YIELD_04 =
        "YIELD-04: Redeemable yield within a cycle never exceeds total yield assets distributed during that cycle (within tolerance)";
    string internal constant YIELD_05 =
        "YIELD-05: Redeemable yield never exceeds yield assets unlocked proportionally to elapsed time in the current cycle (within tolerance)";
    string internal constant YIELD_06 =
        "YIELD-06: Current yield assets never exceed locked assets during the previous cycle";

    string internal constant PREVIEW_01 = "PREVIEW-01: Deposit preview equals actual outcome";
    string internal constant PREVIEW_02 = "PREVIEW-02: Mint preview equals actual outcome";
    string internal constant PREVIEW_03 = "PREVIEW-03: Withdraw preview equals actual outcome";
    string internal constant PREVIEW_04 = "PREVIEW-04: Redeem preview equals actual outcome";

    string internal constant REVERT_01 = "REVERT-01: Deposit does not unexpectedly revert";
    string internal constant REVERT_02 = "REVERT-02: Mint does not unexpectedly revert";
    string internal constant REVERT_03 = "REVERT-03: Withdraw does not unexpectedly revert";
    string internal constant REVERT_04 = "REVERT-04: Redeem does not unexpectedly revert";
    string internal constant REVERT_05 = "REVERT-05: Transfer does not unexpectedly revert";
    string internal constant REVERT_06 = "REVERT-06: Changing OETH supply does not unexpectedly revert";
    string internal constant REVERT_07 = "REVERT-07: Scheduling yield does not unexpectedly revert";
    string internal constant REVERT_08 = "REVERT-08: Function 'totalAssets' never reverts";

    string internal constant GLOBAL_01 = "GLOBAL-01: Total assets never exceed WOETH contract's OETH balance";
    string internal constant GLOBAL_02 = "GLOBAL-02: Tracked assets never exceed WOETH contract's OETH balance";
}
