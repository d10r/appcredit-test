// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import "../src/SuperApp.sol";

// SF framework
import { ERC1820RegistryCompiled } from "@superfluid-finance/ethereum-contracts/contracts/libs/ERC1820RegistryCompiled.sol";
import { SuperfluidFrameworkDeployer } from "@superfluid-finance/ethereum-contracts/contracts/utils/SuperfluidFrameworkDeployer.sol";

using SuperTokenV1Library for ISuperToken;

contract SuperAppTest is Test {
    SuperApp public app;
    SuperfluidFrameworkDeployer.Framework internal sf;
    ISuperToken internal superToken;
    address public A = address(0x42);
    address public B = address(0x43);
    address public Z = address(0x44);

    function setUp() public {
        // deploy prerequisites for SF framework
        vm.etch(ERC1820RegistryCompiled.at, ERC1820RegistryCompiled.bin);

        // deploy SF framework
        SuperfluidFrameworkDeployer deployer = new SuperfluidFrameworkDeployer();
        deployer.deployTestFramework();
        sf = deployer.getFramework();

        app = new SuperApp(sf.host, Z);

        // deploy SuperToken and distribute to accounts
        superToken = deployer.deployPureSuperToken("TestToken", "TST", 10e32);
        superToken.transfer(A, 1e32);
        superToken.transfer(B, 1e32);

        // see https://github.com/superfluid-finance/protocol-monorepo/issues/1697
        superToken.increaseFlowRateAllowance(address(0), 1);
    }

    function testMarkScenario() public {
        vm.startPrank(A);
        superToken.createFlow(address(app), 1e18);
        vm.stopPrank();

        //vm.warp(block.timestamp + 1);

        assertEq(1e18, toU256(superToken.getFlowRate(A, address(app))));

        vm.startPrank(B);
        superToken.createFlow(address(app), 2e18);
        vm.stopPrank();
    }

    // Helpers

    function toU256(int96 i96) internal pure returns (uint256) {
        return uint256(uint96(i96));
    }

    function toI96(uint256 u256) internal pure returns (int96) {
        return int96(uint96(u256));
    }
}
