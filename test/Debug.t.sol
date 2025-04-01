// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {FuzzSetup} from "test/fuzzing/FuzzSetup.sol";

contract DebugTest is Test, FuzzSetup {
    function test_deploy() public view {
        logState();
    }

    function test_happy_path() public {
        // Mint to user
        oeth.approve(address(woeth), 1e16);
        oeth.mint(address(this), 1e16);
        woeth.deposit(1e16, address(this));

        // clean start by warping to the next yield period
        vm.warp(woeth.yieldEnd());

        logState();

        console.log("  * REBASE *");
        uint256 newSupply = oeth.totalSupply() * 110 / 100;
        oeth.changeSupply(newSupply);

        logState();

        console.log("  * WARP & SCHEDULE - 1 DAY *");
        woeth.scheduleYield();
        vm.warp(block.timestamp + 1 days);

        logState();

        console.log("  * WARP & SCHEDULE - 1 HOUR *");
        woeth.scheduleYield();
        vm.warp(block.timestamp + 1 hours);

        logState();
    }

    function test_poc_yieldassets_gt_trackedassets() public {
        oeth.approve(address(woeth), type(uint256).max);
        oeth.mint(address(this), STARTING_BALANCE);

        // Fuzz.deposit(1350221653662188)
        // Fuzz.changeOETHSupply(184158752704330041883)
        // *wait* Time delay: 84971 seconds Block delay: 1
        // Fuzz.withdraw(0)
        // Fuzz.withdrawAll() Time delay: 1 seconds Block delay: 1
        // Fuzz.globalInvariants()

        logState();

        console.log("  * DEPOSIT *");
        woeth.deposit(1350221653662188, address(this));

        logState();

        console.log("  * REBASE *");
        uint256 addedSupply = 184158752704330041883;
        addedSupply = fl.clamp(addedSupply, 1, oeth.totalSupply() / 10);
        console.log("  addedSupply", addedSupply);
        uint256 newSupply = oeth.totalSupply() + addedSupply;
        oeth.changeSupply(newSupply);

        logState();

        console.log("  * WARP & SCHEDULE *");
        vm.warp(woeth.yieldEnd());
        woeth.scheduleYield();

        logState();

        console.log(" * WARP *");
        vm.warp(block.timestamp + 100 seconds);

        logState();

        console.log("  * WITHDRAW ALL *");
        woeth.withdraw(woeth.maxWithdraw(address(this)), address(this), address(this));

        logState();
    }

    function test_yieldpreviewdelta_gt_yieldassets() public {
        oeth.approve(address(woeth), type(uint256).max);
        oeth.mint(address(this), STARTING_BALANCE);

        // *wait* Time delay: 15849 seconds Block delay: 1
        // Fuzz.changeOETHSupply(311991718106855)
        // *wait* Time delay: 67734 seconds Block delay: 1
        // Fuzz.deposit(10346096921702960)
        // Fuzz.deposit(0) Time delay: 85579 seconds Block delay: 1
        // Fuzz.testYieldPerTime()
        // Fuzz.deposit(1)
        // Fuzz.testYieldPerTime()

        console.log("  * WARP *");
        vm.warp(block.timestamp + 15849);

        console.log("  * REBASE *");
        uint256 addedSupply = 311991718106855;
        addedSupply = fl.clamp(addedSupply, 1, oeth.totalSupply() / 10);
        console.log("  addedSupply", addedSupply);
        uint256 newSupply = oeth.totalSupply() + addedSupply;
        oeth.changeSupply(newSupply);

        console.log("  * WARP *");
        vm.warp(block.timestamp + 67734);

        console.log("  * DEPOSIT *");
        woeth.deposit(10346096921702960, address(this));

        console.log("  * WARP *");
        vm.warp(block.timestamp + 85579);

        console.log("  * SCHEDULE *");
        woeth.scheduleYield();

        uint256 balanceBefore = woeth.balanceOf(address(this));
        uint256 previewRedeemBefore = woeth.previewRedeem(woeth.maxRedeem(address(this)));

        console.log("  * DEPOSIT *");
        woeth.deposit(100, address(this));
        woeth.deposit(2, address(this));
        woeth.deposit(1, address(this));

        uint256 balanceAfter = woeth.balanceOf(address(this));
        uint256 previewRedeemAfter = woeth.previewRedeem(woeth.maxRedeem(address(this)));

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);
        console.log("previewRedeemBefore", previewRedeemBefore);
        console.log("previewRedeemAfter", previewRedeemAfter);
        console.log("yieldAssets", woeth.yieldAssets());
    }

    function logState() public view {
        console.log("woeth oeth.balanceOf", oeth.balanceOf(address(woeth)));
        console.log("woeth total supply", woeth.totalSupply());
        console.log("woeth total assets", woeth.totalAssets());

        console.log("woeth.trackedAssets", woeth.trackedAssets());
        console.log("woeth.yieldAssets", woeth.yieldAssets());
        console.log("woeth.yieldEnd", woeth.yieldEnd());
        console.log("block.timestamp", block.timestamp);

        console.log("woeth balance this", woeth.balanceOf(address(this)));
        console.log("preview redeem", woeth.previewRedeem(woeth.balanceOf(address(this))));
    }
}
