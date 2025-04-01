## Overview

Origin Protocol engaged [Perimeter](https://www.perimetersec.io) for an offensive fuzzing suite for WOETH. The primary goal of this engagement was to implement an offensive fuzzing suite targeting the most vulnerable components of the WOETH codebase. During the process, numerous invariants were identified and implemented. This engagement was conducted by Lead Fuzzing Specialist [Rappie](https://twitter.com/rappie_eth). The fuzzing suite was successfully delivered upon the engagement's conclusion.

## Contents
This fuzzing suite was created for the commit hash `a53a8ceb2acf5a6bf39d971e4163a26a2ff84e3d`. The primary goal of this engagement was to implement an offensive fuzzing suite targeting the most vulnerable components of the WOETH codebase. Rather than attempting exhaustive coverage, the objective was to uncover critical vulnerabilities. Additionally, key invariants were defined to validate the correct behavior of WOETH under many different scenarios.

## Setup

1. Installing Echidna

    a. Install Echidna, follow the steps here: [Installation Guide](https://github.com/crytic/echidna#installation) using the latest master branch

2. To fuzz all WOETH invariants using Echidna, run the command: 
    ```
    echidna . --contract Fuzz --config echidna-config.yaml --workers <Number of workers>
    ```

## Scope

Repo: [https://github.com/OriginProtocol/origin-dollar](https://github.com/OriginProtocol/origin-dollar)

Branch: `DanielVF/fixedDayYield`

Commit: `a53a8ceb2acf5a6bf39d971e4163a26a2ff84e3d`

```
src
└── token
    └── WOETH.sol
```

