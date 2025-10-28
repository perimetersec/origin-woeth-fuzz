# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an offensive fuzzing suite for WOETH (Wrapped OETH), an ERC4626 vault that wraps a rebasing token (OETH) and distributes yield slowly over 23-hour cycles to prevent donation attacks. The fuzzing suite was created by Perimeter for Origin Protocol at commit hash `a53a8ceb2acf5a6bf39d971e4163a26a2ff84e3d`.

The target contract is `src/token/WOETH.sol` - an ERC4626 wrapper around OETH that distributes yield over a 23-hour period (defined as `YIELD_TIME = 1 days - 1 hours`).

## Running Fuzzing Campaigns

### Echidna
```bash
echidna . --contract Fuzz --config echidna-config.yaml --workers <number>
```

### Medusa
```bash
medusa fuzz
```

Configuration files:
- `echidna-config.yaml` - Echidna configuration with handler functions blacklisted via `filterFunctions`
- `medusa.json` - Medusa configuration with handlers excluded via `excludeFunctionSignatures`

Both fuzzers target the `Fuzz` contract in assertion testing mode.

## Foundry Commands

This is a Foundry project with standard configuration in `foundry.toml`.

```bash
# Build the project
forge build

# Run tests
forge test

# Run specific test
forge test --match-test <test_name>

# Run tests with verbosity
forge test -vvv
```

## Architecture

### Fuzzing Suite Structure

The fuzzing suite is organized into a hierarchical contract inheritance structure:

```
Fuzz (Main Entry Point)
├── FuzzWOETHOverTime (Time-based invariants)
│   └── FuzzWOETH (Core WOETH handlers)
│       └── FuzzHelper (Helper functions for balance calculations)
│           └── FuzzSetup (Deployment and initialization)
│               ├── FuzzActor (Actor management)
│               │   └── FuzzConfig (Constants)
│               ├── FuzzBase (from fuzzlib)
│               └── PropertiesDescriptions (Invariant descriptions)
└── FuzzIntegrity (Handler integrity checks)
```

### Core Components

**FuzzSetup** (`test/fuzzing/FuzzSetup.sol`):
- Deploys OETH and WOETH contracts
- Initializes 3 actors (0x10000, 0x20000, 0x30000) with large starting balances (1 trillion ether)
- Mints initial WOETH to dead address (0xDEAD) to prevent division by zero

**FuzzWOETH** (`test/fuzzing/FuzzWOETH.sol`):
- Core handlers for WOETH operations: `handler_deposit`, `handler_mint`, `handler_withdraw`, `handler_redeem`
- Yield manipulation: `handler_changeOETHSupply`, `handler_donate`, `handler_scheduleYield`
- Invariant tests: `handler_globalInvariants`, `handler_testSolvability`, `handler_totalAssetsNeverReverts`
- Tracks `totalYieldInjected` and `didRoundDownZero` for sophisticated invariant testing

**FuzzWOETHOverTime** (`test/fuzzing/FuzzWOETHOverTime.sol`):
- Implements time-based invariants using snapshot mechanism
- Tests exchange rate stability, yield distribution over time, and locked yield constraints
- `handler_testYieldOverTime` compares consecutive snapshots to verify yield behavior

**FuzzIntegrity** (`test/fuzzing/FuzzIntegrity.sol`):
- Provides direct fuzzing entry points (`fuzz_*` functions) for each handler
- Wraps handlers with integrity checks using `delegatecall`
- Ignores `ClampError` (used instead of `require` for parameter clamping)

**FuzzHelper** (`test/fuzzing/FuzzHelper.sol`):
- Helper functions for calculating sums: `getWOETHBalanceSum()`, `getRedeemPreviewSum()`
- Includes variants with dead address (`*InclDead()`)

**FuzzActor** (`test/fuzzing/FuzzActor.sol`):
- Defines the 3 actor addresses and manages `currentActor` state
- `setCurrentActor` modifier tracks which actor is calling handlers

**PropertiesDescriptions** (`test/fuzzing/PropertiesDescriptions.sol`):
- String constants for all invariant descriptions organized by category:
  - `TASSETS_*`: Total assets invariants
  - `SOLV_*`: Solvability invariants
  - `YIELD_*`: Yield distribution invariants
  - `PREVIEW_*`: Preview function accuracy
  - `REVERT_*`: Non-reversion properties
  - `GLOBAL_*`: Global system invariants

### WOETH Implementation Details

**Key State Variables** (`src/token/WOETH.sol`):
- `trackedAssets`: Assets acknowledged by the system (updated on deposit/withdraw/mint/redeem)
- `yieldAssets`: Total yield to be distributed over the current cycle (uint128)
- `yieldEnd`: Timestamp when current yield cycle ends (uint64)
- `YIELD_TIME`: 23 hours (82800 seconds)

**Critical Functions**:
- `totalAssets()`: Returns current redeemable assets, accounting for time-based yield unlock
- `scheduleYield()`: Called after every operation; starts new yield cycle if current one ended
  - Caps new yield at 5% of current assets
  - Updates `trackedAssets`, `yieldAssets`, and `yieldEnd`

**Yield Distribution**:
Yield unlocks linearly over 23 hours. The formula in `totalAssets()`:
```solidity
uint256 elapsed = (block.timestamp + YIELD_TIME) - yieldEnd;
uint256 unlockedYield = (yieldAssets * elapsed) / YIELD_TIME;
return trackedAssets + unlockedYield - yieldAssets;
```

### Handler Pattern

All handlers follow a pattern:
1. Use `setCurrentActor` modifier to track the calling actor
2. Clamp inputs to valid ranges using `fl.clamp()` (throws `ClampError` if impossible)
3. Record state before operation
4. Execute operation with `vm.prank(currentActor)` and `try-catch`
5. Assert invariants using `fl.*` functions (from fuzzlib)

Example clamping:
```solidity
oethAmount = fl.clamp(oethAmount, 0, oeth.balanceOf(currentActor));
```

If clamping fails (e.g., range is invalid), throws `ClampError` which is caught by integrity checks.

## Invariant Categories

The fuzzing suite tests 6 categories of invariants:

1. **Total Assets (TASSETS_*)**: Operations only change `totalAssets` by the amount of OETH transferred
2. **Solvability (SOLV_*)**: All users can always fully redeem; sum of redeem previews equals total assets
3. **Yield Distribution (YIELD_*)**: Yield unlocks correctly over time; exchange rate stability
4. **Preview Accuracy (PREVIEW_*)**: Preview functions return exact outcomes
5. **Non-Reversion (REVERT_*)**: Operations don't revert unexpectedly
6. **Global (GLOBAL_*)**: `totalAssets` and `trackedAssets` never exceed actual OETH balance

Tolerances are typically `ACTORS.length + 1` (4 wei) to account for rounding across multiple actors.

## Important Notes

- The suite excludes certain handlers from direct fuzzing using blacklists/exclude lists in both Echidna and Medusa configs
- Handlers like `handler_testYieldOverTime` are test functions, not operations - they verify invariants
- `didRoundDownZero` flag tracks edge cases where operations round down to zero shares/assets
- The "dead address" (0xDEAD) is included to prevent initial division by zero issues
- Uses `fuzzlib` for base functionality (`FuzzBase`, `IHevm`, `vm`)
