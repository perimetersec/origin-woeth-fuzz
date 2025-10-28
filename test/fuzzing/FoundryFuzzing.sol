// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test} from "forge-std/Test.sol";
import {Fuzz} from "./Fuzz.sol";

/**
 * @title FoundryFuzzing
 * @author Rappie <rappie@perimetersec.io>
 * @notice Bridge contract to run Echidna/Medusa fuzzing harness in Foundry's invariant testing mode
 * @dev This allows the same fuzzing suite to be used with both Echidna/Medusa and Foundry
 */
contract FoundryFuzzing is Fuzz, Test {
    function setUp() public {
        vm.label(address(this), "FuzzingHarness");
        vm.label(address(woeth), "WOETH");
        vm.label(address(oeth), "OETH");

        // Configure which functions Foundry's invariant fuzzer should call
        bytes4[] memory selectors = new bytes4[](23);

        // Core WOETH operation tests
        selectors[0] = this.fuzz_deposit.selector;
        selectors[1] = this.fuzz_mint.selector;
        selectors[2] = this.fuzz_withdraw.selector;
        selectors[3] = this.fuzz_withdrawAll.selector;
        selectors[4] = this.fuzz_redeem.selector;
        selectors[5] = this.fuzz_redeemAll.selector;
        selectors[6] = this.fuzz_transferWOETH.selector;

        // Yield manipulation tests
        selectors[7] = this.fuzz_changeOETHSupply.selector;
        selectors[8] = this.fuzz_donate.selector;
        selectors[9] = this.fuzz_scheduleYield.selector;

        // Time manipulation
        selectors[10] = this.fuzz_warpToYieldEnd.selector;
        selectors[11] = this.warpForward.selector;
        selectors[12] = this.warpAndRoll.selector;

        // Invariant checks (these are called by the fuzzer as part of the sequence)
        selectors[13] = this.fuzz_totalAssetsNeverReverts.selector;
        selectors[14] = this.fuzz_testRedeemSumVsTotalAssets.selector;
        selectors[15] = this.fuzz_testYieldIsDistributed.selector;
        selectors[16] = this.fuzz_globalInvariants.selector;
        selectors[17] = this.fuzz_testYieldOverTime.selector;
        selectors[18] = this.fuzz_testSolvability.selector;

        // Helper functions
        selectors[19] = this.handler_deposit.selector;
        selectors[20] = this.handler_mint.selector;
        selectors[21] = this.handler_withdraw.selector;
        selectors[22] = this.handler_redeem.selector;

        targetSelector(FuzzSelector({addr: address(this), selectors: selectors}));
        targetContract(address(this));

        // Configure senders to match Echidna/Medusa configuration
        targetSender(ADDRESS_ACTOR1);
        targetSender(ADDRESS_ACTOR2);
        targetSender(ADDRESS_ACTOR3);
    }

    /**
     * @notice Warp time forward by a bounded amount
     * @param timeAmount Amount of time to warp forward (will be bounded)
     */
    function warpForward(uint256 timeAmount) public {
        // Bound to reasonable time jumps (max ~7 days)
        timeAmount = timeAmount % 604800;
        if (timeAmount > 0) {
            vm.warp(block.timestamp + timeAmount);
        }
    }

    /**
     * @notice Warp time and roll blocks forward
     * @param timeAmount Amount of time to warp forward
     * @param blockAmount Number of blocks to roll forward
     */
    function warpAndRoll(uint256 timeAmount, uint256 blockAmount) public {
        // Match Echidna/Medusa defaults
        timeAmount = timeAmount % 604800; // max ~7 days
        blockAmount = blockAmount % 60480; // reasonable block jumps

        if (timeAmount > 0) {
            vm.warp(block.timestamp + timeAmount);
        }
        if (blockAmount > 0) {
            vm.roll(block.number + blockAmount);
        }
    }

    /**
     * @notice Check all global invariants
     * @dev Called by invariant_* functions after each fuzz run
     */
    function checkAllGlobalInvariants() internal {
        // Global invariants: totalAssets and trackedAssets <= OETH balance
        handler_globalInvariants();

        // Test that totalAssets never reverts
        handler_totalAssetsNeverReverts();

        // Heavy invariants (optional, uncomment to enable):
        // handler_testSolvability(); // Tests all users can withdraw
        // handler_testRedeemSumVsTotalAssets(); // Sum of redeems equals total assets
    }

    /**
     * @notice Invariant workers - run after each fuzz sequence
     * @dev Multiple workers allow for parallel testing of different invariants
     */
    function invariant_worker1() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker2() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker3() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker4() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker5() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker6() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker7() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker8() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker9() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker10() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker11() public {
        checkAllGlobalInvariants();
    }

    function invariant_worker12() public {
        checkAllGlobalInvariants();
    }
}
