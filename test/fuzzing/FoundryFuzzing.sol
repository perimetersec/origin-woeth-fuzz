// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test} from "forge-std/Test.sol";
import {Fuzz} from "./Fuzz.sol";

contract FoundryFuzzing is Fuzz, Test {
    function setUp() public {
        bytes4[] memory selectors = new bytes4[](16);

        selectors[0] = this.fuzz_deposit.selector;
        selectors[1] = this.fuzz_mint.selector;
        selectors[2] = this.fuzz_withdraw.selector;
        selectors[3] = this.fuzz_withdrawAll.selector;
        selectors[4] = this.fuzz_redeem.selector;
        selectors[5] = this.fuzz_redeemAll.selector;
        selectors[6] = this.fuzz_transferWOETH.selector;
        selectors[7] = this.fuzz_changeOETHSupply.selector;
        selectors[8] = this.fuzz_donate.selector;
        selectors[9] = this.fuzz_scheduleYield.selector;
        selectors[10] = this.fuzz_warpToYieldEnd.selector;
        selectors[11] = this.fuzz_testYieldIsDistributed.selector;
        selectors[12] = this.fuzz_testYieldOverTime.selector;
        selectors[13] = this.fuzz_testSolvability.selector;
        selectors[14] = this.handler_scheduleYield.selector;
        selectors[15] = this.warpAndRoll.selector;

        targetSelector(FuzzSelector({addr: address(this), selectors: selectors}));
        targetContract(address(this));

        targetSender(ADDRESS_ACTOR1);
        targetSender(ADDRESS_ACTOR2);
        targetSender(ADDRESS_ACTOR3);
    }

    function warpAndRoll(uint256 timeAmount, uint256 blockAmount) public {
        timeAmount = timeAmount % 604800; // echidna default
        blockAmount = blockAmount % 60480; // echidna default
        vm.warp(block.timestamp + timeAmount);
        vm.roll(block.number + blockAmount);
    }

    function checkAllGlobalInvariants() internal {
        handler_globalInvariants();
        handler_totalAssetsNeverReverts();
        handler_testRedeemSumVsTotalAssets();
    }

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
