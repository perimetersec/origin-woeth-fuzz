// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzHelper} from "./FuzzHelper.sol";
import {vm} from "fuzzlib/IHevm.sol";

/**
 * @title FuzzWOETH
 * @author Rappie <rappie@perimetersec.io>
 * @notice Contract containing handlers for the WOETH contract
 */
contract FuzzWOETH is FuzzHelper {
    // Track total amount of yield injected
    uint256 totalYieldInjected;
    // Track if actions like `deposit` ever rounded down to zero
    bool didRoundDownZero;

    /**
     * @notice Deposits OETH into the WOETH contract
     * @param oethAmount Amount of OETH to deposit
     */
    function handler_deposit(uint256 oethAmount) public setCurrentActor {
        oethAmount = fl.clamp(oethAmount, 0, oeth.balanceOf(currentActor));

        uint256 preview = woeth.previewDeposit(oethAmount);
        uint256 totalAssetsBefore = woeth.totalAssets();

        vm.prank(currentActor);
        try woeth.deposit(oethAmount, currentActor) returns (uint256 woethAmount) {
            uint256 totalAssetsAfter = woeth.totalAssets();

            if (oethAmount > 0 && woethAmount == 0) {
                didRoundDownZero = true;
            }

            // Deposits do not affect total assets except OETH transferred by user
            fl.eq(totalAssetsAfter, totalAssetsBefore + oethAmount, TASSETS_01);
            // Deposit preview equals actual outcome
            fl.eq(woethAmount, preview, PREVIEW_01);
        } catch {
            // Deposit does not unexpectedly revert
            fl.t(false, REVERT_01);
        }
    }

    /**
     * @notice Mints WOETH from the WOETH contract
     * @param woethAmount Amount of WOETH to mint
     */
    function handler_mint(uint256 woethAmount) public setCurrentActor {
        uint256 previewAmount = woeth.previewDeposit(oeth.balanceOf(currentActor));
        woethAmount = fl.clamp(woethAmount, 0, previewAmount);

        uint256 preview = woeth.previewMint(woethAmount);
        uint256 totalAssetsBefore = woeth.totalAssets();

        vm.prank(currentActor);
        try woeth.mint(woethAmount, currentActor) returns (uint256 oethAmount) {
            uint256 totalAssetsAfter = woeth.totalAssets();

            if (woethAmount > 0 && oethAmount == 0) {
                didRoundDownZero = true;
            }

            // Mint does not affect total assets except OETH transferred by user
            fl.eq(totalAssetsAfter, totalAssetsBefore + oethAmount, TASSETS_02);
            // Mint preview equals actual outcome
            fl.eq(oethAmount, preview, PREVIEW_02);
        } catch {
            // Mint does not unexpectedly revert
            fl.t(false, REVERT_02);
        }
    }

    /**
     * @notice Withdraws OETH from the WOETH contract
     * @param oethAmount Amount of OETH to withdraw
     */
    function handler_withdraw(uint256 oethAmount) public setCurrentActor {
        oethAmount = fl.clamp(oethAmount, 0, woeth.maxWithdraw(currentActor));

        uint256 preview = woeth.previewWithdraw(oethAmount);
        uint256 totalAssetsBefore = woeth.totalAssets();

        vm.prank(currentActor);
        try woeth.withdraw(oethAmount, currentActor, currentActor) returns (uint256 woethAmount) {
            uint256 totalAssetsAfter = woeth.totalAssets();

            if (oethAmount > 0 && woethAmount == 0) {
                didRoundDownZero = true;
            }

            // Withdraw does not change total assets beyond OETH transferred by user
            fl.eq(totalAssetsAfter, totalAssetsBefore - oethAmount, TASSETS_03);
            // Withdraw preview matches actual result
            fl.eq(woethAmount, preview, PREVIEW_03);
        } catch {
            // Withdraw does not unexpectedly revert
            fl.t(false, REVERT_03);
        }
    }

    /**
     * @notice Withdraws all OETH from the WOETH contract
     */
    function handler_withdrawAll() public setCurrentActor {
        handler_withdraw(woeth.maxWithdraw(currentActor));
    }

    /**
     * @notice Redeems WOETH from the WOETH contract
     * @param woethAmount Amount of WOETH to redeem
     */
    function handler_redeem(uint256 woethAmount) public setCurrentActor {
        woethAmount = fl.clamp(woethAmount, 0, woeth.maxRedeem(currentActor));

        uint256 preview = woeth.previewRedeem(woethAmount);
        uint256 totalAssetsBefore = woeth.totalAssets();

        vm.prank(currentActor);
        try woeth.redeem(woethAmount, currentActor, currentActor) returns (uint256 oethAmount) {
            uint256 totalAssetsAfter = woeth.totalAssets();

            if (woethAmount > 0 && oethAmount == 0) {
                didRoundDownZero = true;
            }

            // Redeem does not change total assets beyond OETH transferred by user
            fl.eq(totalAssetsAfter, totalAssetsBefore - oethAmount, TASSETS_04);
            // Redeem preview matches actual result
            fl.eq(oethAmount, preview, PREVIEW_04);
        } catch {
            // Redeem does not unexpectedly revert
            fl.t(false, REVERT_04);
        }
    }

    /**
     * @notice Redeems all WOETH from the WOETH contract
     */
    function handler_redeemAll() public setCurrentActor {
        handler_redeem(woeth.maxRedeem(currentActor));
    }

    /**
     * @notice Transfers WOETH to another actor
     * @param toSelector Index of the actor to transfer to
     * @param amount Amount of WOETH to transfer
     */
    function handler_transferWOETH(uint8 toSelector, uint256 amount) public setCurrentActor {
        address to = ACTORS[fl.clamp(toSelector, 0, ACTORS.length - 1)];
        amount = fl.clamp(amount, 0, woeth.balanceOf(currentActor));

        uint256 totalAssetsBefore = woeth.totalAssets();

        vm.prank(currentActor);
        try woeth.transfer(to, amount) {
            uint256 totalAssetsAfter = woeth.totalAssets();

            // Transfer does not change total assets
            fl.eq(totalAssetsBefore, totalAssetsAfter, TASSETS_05);
        } catch {
            // Transfer does not unexpectedly revert
            fl.t(false, REVERT_05);
        }
    }

    /**
     * @notice Changes the total supply of OETH (rebase)
     * @param addedSupply Amount of OETH to add to the supply
     */
    function handler_changeOETHSupply(uint256 addedSupply) public setCurrentActor {
        addedSupply = fl.clamp(addedSupply, 1, oeth.totalSupply() / 10);
        uint256 newSupply = oeth.totalSupply() + addedSupply;

        uint256 totalAssetsBefore = woeth.totalAssets();

        try oeth.changeSupply(newSupply) {
            uint256 totalAssetsAfter = woeth.totalAssets();

            // Changing OETH supply does not change total assets
            fl.eq(totalAssetsAfter, totalAssetsBefore, TASSETS_06);

            totalYieldInjected += addedSupply;
        } catch {
            // Changing OETH supply does not unexpectedly revert
            fl.t(false, REVERT_06);
        }
    }

    /**
     * @notice Donates OETH to the WOETH contract
     * @param oethAmount Amount of OETH to donate
     */
    function handler_donate(uint256 oethAmount) public setCurrentActor {
        if (oeth.balanceOf(currentActor) == 0) revert ClampError();
        oethAmount = fl.clamp(oethAmount, 1, oeth.balanceOf(currentActor));

        uint256 totalAssetsBefore = woeth.totalAssets();

        vm.prank(currentActor);
        oeth.transfer(address(woeth), oethAmount);

        uint256 totalAssetsAfter = woeth.totalAssets();

        // Donating does not change total assets
        fl.eq(totalAssetsBefore, totalAssetsAfter, TASSETS_07);

        totalYieldInjected += oethAmount;
    }

    /**
     * @notice Starts a new yield cycle
     */
    function handler_scheduleYield() public {
        uint256 totalAssetsBefore = woeth.totalAssets();

        try woeth.scheduleYield() {
            uint256 totalAssetsAfter = woeth.totalAssets();

            // Scheduling yield does not change total assets
            fl.eq(totalAssetsBefore, totalAssetsAfter, TASSETS_08);
        } catch {
            // Scheduling yield does not unexpectedly revert
            fl.t(false, REVERT_07);
        }
    }

    /**
     * @notice Tests the solvability of the WOETH contract
     */
    function handler_testSolvability() public {
        for (uint256 i = 0; i < ACTORS.length; i++) {
            address actor = ACTORS[i];

            vm.prank(actor);
            try FuzzWOETH(address(this)).handler_withdrawAll() {}
            catch {
                // All users can fully redeem their wOETH at any time
                fl.t(false, SOLV_01);
            }
        }
    }

    /**
     * @notice Warps close to the end of the yield cycle
     * @param _buffer Seed for small timestamp adjustments near cycle end
     */
    function handler_warpToYieldEnd(uint8 _buffer) public {
        // Map _buffer from [0,255] to [-2, 2]
        int8 buffer = int8(int256((uint256(_buffer) * 4) / 255) - 2);

        // Warp close to yield end
        uint256 timestamp = uint256(int256(uint256(woeth.yieldEnd())) + buffer);

        // Prevent warping to the past
        if (timestamp <= block.timestamp) revert ClampError();

        // Perform warp
        vm.warp(timestamp);
    }

    /**
     * @notice Tests that totalAssets never reverts
     */
    function handler_totalAssetsNeverReverts() public {
        try woeth.totalAssets() {}
        catch {
            // totalAssets never reverts
            fl.t(false, REVERT_08);
        }
    }

    /**
     * @notice Tests that redeem preview sum equals total assets
     */
    function handler_testRedeemSumVsTotalAssets() public {
        uint256 redeemPreviewSum = getRedeemPreviewSumInclDead();
        uint256 totalAssets = woeth.totalAssets();

        uint256 diff = fl.diff(redeemPreviewSum, totalAssets);
        uint256 tolerance = ACTORS.length + 1; // actors + dead

        // Sum of all users' redeem previews equals total assets
        fl.lte(diff, tolerance, SOLV_02);
    }

    /**
     * @notice Tests that yield is distributed correctly
     * @param delay Amount of seconds to warp into the future
     */
    function handler_testYieldIsDistributed(uint256 delay) public {
        if (woeth.yieldEnd() <= block.timestamp) revert ClampError();

        delay = fl.clamp(delay, 0, 365 days);

        uint256 undistributedYield = woeth.trackedAssets() - woeth.totalAssets();
        uint256 redeemPreviewSumBefore = getRedeemPreviewSumInclDead();

        vm.warp(woeth.yieldEnd() + delay);

        uint256 redeemPreviewSumAfter = getRedeemPreviewSumInclDead();

        // Redeem preview strictly increases over time
        fl.gte(redeemPreviewSumAfter, redeemPreviewSumBefore, SOLV_03);

        uint256 previewSumDiff = redeemPreviewSumAfter - redeemPreviewSumBefore;

        uint256 yieldDiff = fl.diff(previewSumDiff, undistributedYield);
        uint256 tolerance = ACTORS.length + 1; // actors + dead

        // All currently undistributed yield is fully distributed at cycle end (within tolerance)
        fl.lte(yieldDiff, tolerance, YIELD_01);
    }

    /**
     * @notice Tests global invariants
     */
    function handler_globalInvariants() public {
        uint256 oethBalance = oeth.balanceOf(address(woeth));
        uint256 totalAssets = woeth.totalAssets();
        uint256 trackedAssets = woeth.trackedAssets();

        // Total assets never exceed WOETH contract's OETH balance
        fl.lte(totalAssets, oethBalance, GLOBAL_01);
        // Tracked assets never exceed WOETH contract's OETH balance
        fl.lte(trackedAssets, oethBalance, GLOBAL_02);
    }
}
