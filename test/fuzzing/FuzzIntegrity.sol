// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzWOETH} from "./FuzzWOETH.sol";
import {FuzzWOETHOverTime} from "./FuzzWOETHOverTime.sol";

/**
 * @title FuzzIntegrity
 * @author Rappie <rappie@perimetersec.io>
 * @notice Checks for errors in the handlers
 */
contract FuzzIntegrity is FuzzWOETH, FuzzWOETHOverTime {
    /**
     * @notice Checks the integrity of handler_deposit
     */
    function fuzz_deposit(uint256 oethAmount) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_deposit.selector, oethAmount);
        _testIntegrity(callData, "INTEGRITY: deposit");
    }

    /**
     * @notice Checks the integrity of handler_mint
     */
    function fuzz_mint(uint256 woethAmount) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_mint.selector, woethAmount);
        _testIntegrity(callData, "INTEGRITY: mint");
    }

    /**
     * @notice Checks the integrity of handler_withdraw
     */
    function fuzz_withdraw(uint256 oethAmount) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_withdraw.selector, oethAmount);
        _testIntegrity(callData, "INTEGRITY: withdraw");
    }

    /**
     * @notice Checks the integrity of handler_withdrawAll
     */
    function fuzz_withdrawAll() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_withdrawAll.selector);
        _testIntegrity(callData, "INTEGRITY: withdrawAll");
    }

    /**
     * @notice Checks the integrity of handler_redeem
     */
    function fuzz_redeem(uint256 woethAmount) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_redeem.selector, woethAmount);
        _testIntegrity(callData, "INTEGRITY: redeem");
    }

    /**
     * @notice Checks the integrity of handler_redeemAll
     */
    function fuzz_redeemAll() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_redeemAll.selector);
        _testIntegrity(callData, "INTEGRITY: redeemAll");
    }

    /**
     * @notice Checks the integrity of handler_transferWOETH
     */
    function fuzz_transferWOETH(uint8 toSelector, uint256 amount) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_transferWOETH.selector, toSelector, amount);
        _testIntegrity(callData, "INTEGRITY: transferWOETH");
    }

    /**
     * @notice Checks the integrity of handler_changeOETHSupply
     */
    function fuzz_changeOETHSupply(uint256 addedSupply) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_changeOETHSupply.selector, addedSupply);
        _testIntegrity(callData, "INTEGRITY: changeOETHSupply");
    }

    /**
     * @notice Checks the integrity of handler_donate
     */
    function fuzz_donate(uint256 oethAmount) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_donate.selector, oethAmount);
        _testIntegrity(callData, "INTEGRITY: donate");
    }

    /**
     * @notice Checks the integrity of handler_scheduleYield
     */
    function fuzz_scheduleYield() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_scheduleYield.selector);
        _testIntegrity(callData, "INTEGRITY: scheduleYield");
    }

    /**
     * @notice Checks the integrity of handler_testSolvability
     */
    function fuzz_testSolvability() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_testSolvability.selector);
        _testIntegrity(callData, "INTEGRITY: testSolvability");
    }

    /**
     * @notice Checks the integrity of handler_warpToYieldEnd
     */
    function fuzz_warpToYieldEnd(uint8 _buffer) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_warpToYieldEnd.selector, _buffer);
        _testIntegrity(callData, "INTEGRITY: warpToYieldEnd");
    }

    /**
     * @notice Checks the integrity of handler_totalAssetsNeverReverts
     */
    function fuzz_totalAssetsNeverReverts() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_totalAssetsNeverReverts.selector);
        _testIntegrity(callData, "INTEGRITY: totalAssetsNeverReverts");
    }

    /**
     * @notice Checks the integrity of handler_testRedeemSumVsTotalAssets
     */
    function fuzz_testRedeemSumVsTotalAssets() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_testRedeemSumVsTotalAssets.selector);
        _testIntegrity(callData, "INTEGRITY: testRedeemSumVsTotalAssets");
    }

    /**
     * @notice Checks the integrity of handler_testYieldIsDistributed
     */
    function fuzz_testYieldIsDistributed(uint256 delay) public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_testYieldIsDistributed.selector, delay);
        _testIntegrity(callData, "INTEGRITY: testYieldIsDistributed");
    }

    /**
     * @notice Checks the integrity of handler_globalInvariants
     */
    function fuzz_globalInvariants() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETH.handler_globalInvariants.selector);
        _testIntegrity(callData, "INTEGRITY: globalInvariants");
    }

    /**
     * @notice Checks the integrity of handler_testYieldOverTime
     */
    function fuzz_testYieldOverTime() public {
        bytes memory callData = abi.encodeWithSelector(FuzzWOETHOverTime.handler_testYieldOverTime.selector);
        _testIntegrity(callData, "INTEGRITY: testYieldOverTime");
    }

    /**
     * @notice Internal helper function to check the integrity of a handler
     */
    function _testIntegrity(bytes memory callData, string memory message) internal {
        (bool success, bytes memory returnData) = address(this).delegatecall(callData);

        bytes4 errorSelector = bytes4(returnData);
        if (!(errorSelector == ClampError.selector)) {
            fl.t(success, message);
        }
    }
}
