// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { BaseScript } from "./Base.s.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {PoolManagerTester} from "../src/PoolManagerTester.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {MockERC20} from "@uniswap/v4-core/test/foundry-tests/utils/MockERC20.sol";
import {UniswapHooks} from "../src/UniswapHooks.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {HookDeployer} from "../test/utils/HookDeployer.sol";


contract DeployPoolScript is BaseScript {
    using CurrencyLibrary for Currency;

    IPoolManager public poolManager;
    
    bytes public constant ZERO_BYTES = new bytes(0);
    uint160 public constant SQRT_RATIO_1_1 = 79228162514264337593543950336;
    address constant CREATE2_DEPLOYER = address(0x34d014758297c00FeA49935FCe172677904d51EF);

    function run() public broadcaster {
        
        poolManager = new PoolManager(500000);

        // poolManager = IPoolManager();

        MockERC20 tokenA = new MockERC20("TestA", "TA", 18, 100 ether);
        MockERC20 tokenB = new MockERC20("TestB", "TB", 18, 100 ether);

        // tokenA.approve(address(poolManager), 100 ether);
        // tokenB.approve(address(poolManager), 100 ether);

        Currency currency0 = Currency.wrap(address(tokenA));
        Currency currency1 = Currency.wrap(address(tokenB));
        // Make sure the order is correct
        if (currency0 > currency1) {
            // Swap Currency
            Currency tmp = currency1;
            currency1 = currency0;
            currency0 = tmp;
        }

        uint160 sqrtPriceLimitX96ToSet = 3266570274706945504500000000000;

        // Deploy Hooks
        address uniswapHookAddress = 0x610178dA211FEF7D417bC0e6FeD39F05609AD788; 
        // replaced with UniswapHooksFactory contract address
        
        // address lensHubAddress = 0x00CAC06Dd0BB4103f8b62D280fE9BCEE8f26fD59;

        // LensAuthHook lensAuthHook = new LensAuthHook(poolManager, lensHubAddress);
        
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_INITIALIZE_FLAG
        );
        bytes memory hookBytecode = abi.encodePacked(type(UniswapHooks).creationCode, 
                                    abi.encode(address(poolManager),
                                    address(uniswapHookAddress)));

        (address hookAddressPreCaculated, uint256 salt) = HookDeployer.mineSalt(CREATE2_DEPLOYER, flags, hookBytecode);
        UniswapHooks uniswapHooks = new UniswapHooks{salt: bytes32(salt)}(IPoolManager(address(poolManager)), 
                                    address(uniswapHookAddress));
        require(address(uniswapHooks) == hookAddressPreCaculated, 
                                        "Deploy: hook address mismatch");

        // Hooks End
        // address hookAddressPreCaculated = address(lensAuthHook);

        PoolKey memory keyToAdd = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: 3000,
            hooks: IHooks(address(uniswapHooks)),
            tickSpacing: 1
        });

        // Todo:: check if the pool key already exits
        poolManager.initialize(keyToAdd, sqrtPriceLimitX96ToSet, ZERO_BYTES);

        PoolManagerTester tester = new PoolManagerTester(address(poolManager), keyToAdd);
        tokenA.approve(address(tester), 100 ether);
        tokenB.approve(address(tester), 100 ether);

        // // modifyPosition
        // tester.runMP(73781, 74959, 1 ether); // 1600 1800
        // // Swap
        // tester.runSwap(true, 100, SQRT_RATIO_1_1);
    }
}