// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { UniswapHooksFactory } from "../src/UniswapHooksFactory.sol";
import { BaseScript } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcaster returns (UniswapHooksFactory uniswapHooksFactory) {
        uniswapHooksFactory = new UniswapHooksFactory();
    }
}
