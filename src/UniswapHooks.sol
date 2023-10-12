// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {
    IPoolManager, Hooks, IHooks, BaseHook, BalanceDelta
} from "@uniswap-periphery/v4-periphery/contracts/BaseHook.sol";
import { IHookFeeManager } from "@uniswap/v4-core/contracts/interfaces/IHookFeeManager.sol";
import { IDynamicFeeManager } from "@uniswap/v4-core/contracts/interfaces/IDynamicFeeManager.sol";
import { console2 } from "forge-std/console2.sol";

contract UniswapHooks is BaseHook, IHookFeeManager, IDynamicFeeManager {
    address public owner;

    constructor(address _owner, IPoolManager _poolManager) BaseHook(_poolManager) {
        owner = _owner;
    }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: true,
            afterInitialize: true,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    /// @inheritdoc IHooks
    function beforeInitialize(
        address, // sender
        IPoolManager.PoolKey calldata, // key
        uint160 // sqrtPriceX96
    )
        external
        pure
        override
        returns (bytes4)
    {
        console2.log("beforeInitialize");
        return IHooks.beforeInitialize.selector;
    }

    /// @inheritdoc IHooks
    function afterInitialize(
        address, // sender
        IPoolManager.PoolKey calldata, // key
        uint160, // sqrtPriceX96
        int24 // tick
    )
        external
        pure
        override
        returns (bytes4)
    {
        console2.log("afterInitialize");
        return IHooks.afterInitialize.selector;
    }
}
