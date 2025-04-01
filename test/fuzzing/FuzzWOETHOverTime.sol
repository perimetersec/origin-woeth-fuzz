// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzWOETH} from "./FuzzWOETH.sol";
import {vm} from "fuzzlib/IHevm.sol";

/**
 * @title FuzzWOETHOverTime
 * @author Rappie <rappie@perimetersec.io>
 * @notice Contract containing handlers for the WOETH contract
 */
contract FuzzWOETHOverTime is FuzzWOETH {
    /// @notice Snapshot struct for tracking key values over time to test invariants
    struct Snapshot {
        uint256 totalYieldInjected; // Total yield injected into the system
        uint256 oethBalance; // OETH balance held by the WOETH contract
        uint256 balanceSum; // Sum of all WOETH balances across actors
        uint256 exchangeRate; // Exchange rate of WOETH to OETH
        uint256 totalAssets; // Total assets in vault
        uint256 trackedAssets; // Tracked assets in vault
        uint256 yieldAssets; // Yield assets in vault
        uint256 redeemPreviewSum; // Sum of all `previewRedeem` values
        uint256 timestamp; // block.timestamp
        uint256 yieldEnd; // Timestamp of the end of the yield cycle
    }

    // Variables used for tracking snapshots
    bool yieldOverTimeInitialized;
    Snapshot lastSnapshot;

    /**
     * @notice Tests the invariants of the WOETH contract over time
     */
    function handler_testYieldOverTime() public {
        Snapshot memory currSnapshot = getSnapshot();

        if (!yieldOverTimeInitialized) {
            yieldOverTimeInitialized = true;
            lastSnapshot = currSnapshot;
            return;
        }

        testExchangeRate(lastSnapshot, currSnapshot);
        testRedeemDeltaPositive(lastSnapshot, currSnapshot);
        testRedeemDeltaVsYieldAssets(lastSnapshot, currSnapshot);
        testYieldAssetsVsLastLockedYield(lastSnapshot, currSnapshot);

        lastSnapshot = currSnapshot;
    }

    /**
     * @notice Tests the exchange rate over time
     * @param last Last snapshot
     * @param curr Current snapshot
     */
    function testExchangeRate(Snapshot memory last, Snapshot memory curr) internal {
        uint256 timeDelta = curr.timestamp - last.timestamp;

        if (timeDelta != 0) return;

        // If deposit/withdraw results were zero while nonzero tokens went in
        // (e.g. due to depositing 1 while shares:assets is below 1:1),
        // we cannot use the deltas to full precision so we skip the invariant
        if (didRoundDownZero) return;

        uint256 diff = fl.diff(curr.exchangeRate, last.exchangeRate);
        uint256 tolerance = last.exchangeRate / 1e14;

        // Exchange rate remains constant within a single block
        fl.lte(diff, tolerance, YIELD_02);
    }

    /**
     * @notice Tests the redeem delta over time
     * @param last Last snapshot
     * @param curr Current snapshot
     */
    function testRedeemDeltaPositive(Snapshot memory last, Snapshot memory curr) internal {
        int256 balanceDelta = int256(curr.balanceSum) - int256(last.balanceSum);
        int256 redeemPreviewDelta = int256(curr.redeemPreviewSum) - int256(last.redeemPreviewSum);

        if (balanceDelta != 0) return;

        int256 tolerance = int256(ACTORS.length) + 1; // actors + dead

        // Redeem preview never decreases without interactions with WOETH
        // Note: It may increase due to yield distribution
        fl.gte(redeemPreviewDelta, 0 - tolerance, YIELD_03);
    }

    /**
     * @notice Tests the redeem delta vs yield assets over time
     * @param last Last snapshot
     * @param curr Current snapshot
     */
    function testRedeemDeltaVsYieldAssets(Snapshot memory last, Snapshot memory curr) internal {
        int256 balanceDelta = int256(curr.balanceSum) - int256(last.balanceSum);
        int256 redeemPreviewDelta = int256(curr.redeemPreviewSum) - int256(last.redeemPreviewSum);
        uint256 timeDelta = curr.timestamp - last.timestamp;
        bool sameYieldCycle = curr.yieldEnd == last.yieldEnd;

        // Ignore cases where yield is slightly negative due to rounding errors.
        if (redeemPreviewDelta < 0) return;

        if (balanceDelta != 0) return;
        if (!sameYieldCycle) return;

        // If deposit/withdraw results were zero while nonzero tokens went in
        // (e.g. due to depositing 1 while shares:assets is below 1:1),
        // we cannot use the deltas to full precision so we skip the invariant
        if (didRoundDownZero) return;

        uint256 tolerance = fl.max(ACTORS.length + 1, curr.redeemPreviewSum / 1e14);

        // Redeemable yield within a cycle never exceeds total yield assets distributed
        fl.lte(uint256(redeemPreviewDelta), curr.yieldAssets + tolerance, YIELD_04);

        if (timeDelta > 0) {
            // Calculation taken from WOETH::totalAssets()
            uint256 unlockedYield = (curr.yieldAssets * timeDelta) / woeth.YIELD_TIME();

            // Redeemable yield never exceeds unlocked yield
            fl.lte(uint256(redeemPreviewDelta), unlockedYield + tolerance, YIELD_05);
        }
    }

    /**
     * @notice Tests the yield assets vs locked yield over time
     * @param last Last snapshot
     * @param curr Current snapshot
     */
    function testYieldAssetsVsLastLockedYield(Snapshot memory last, Snapshot memory curr) internal {
        int256 yieldInjectedDelta = int256(curr.totalYieldInjected) - int256(last.totalYieldInjected);
        int256 oethBalanceDelta = int256(curr.oethBalance) - int256(last.oethBalance);
        bool sameYieldCycle = curr.yieldEnd == last.yieldEnd;
        uint256 lastLockedYield = last.oethBalance - last.trackedAssets;

        if (oethBalanceDelta != 0) return;

        // Testing for no change in OETH balance is not enough. It does not detect a user withdrawing
        // and then donating the same amount, which does increase locked yield.
        if (yieldInjectedDelta != 0) return;

        if (sameYieldCycle) return;

        // Current yield assets never exceed locked assets during the previous cycle
        fl.lte(curr.yieldAssets, lastLockedYield, YIELD_06);
    }

    // @notice Returns a snapshot of the state of the protocol
    // @return snapshot Snapshot
    function getSnapshot() internal view returns (Snapshot memory snapshot) {
        snapshot = Snapshot({
            totalYieldInjected: totalYieldInjected,
            oethBalance: oeth.balanceOf(address(woeth)),
            balanceSum: getWOETHBalanceSum(),
            exchangeRate: woeth.convertToAssets(1e18),
            totalAssets: woeth.totalAssets(),
            trackedAssets: woeth.trackedAssets(),
            yieldAssets: woeth.yieldAssets(),
            redeemPreviewSum: getRedeemPreviewSum(),
            timestamp: block.timestamp,
            yieldEnd: woeth.yieldEnd()
        });
    }
}
