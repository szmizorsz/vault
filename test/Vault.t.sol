// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/mock/MockToken.sol";

contract VaultTest is Test {
    Vault public vault;
    MockToken public mockToken;
    address public feeCollector = address(12345);
    uint256 public feePercentage = 30000000000000000;
    address public depositor = address(1);

    function setUp() public {
        mockToken = new MockToken();
        vault = new Vault(address(mockToken), feeCollector, feePercentage);
    }

    function testEverythingIsSet() public {
        assertEq(address(vault.token()), address(mockToken));
        assertEq(vault.feeCollector(), feeCollector);
        assertEq(vault.feePercentage(), feePercentage);
    }

    function testFirstDeposit() public {
        uint256 initialDeposit = 1000;
        mockToken.mint(depositor, initialDeposit);

        vm.startPrank(depositor);

        mockToken.approve(address(vault), initialDeposit);
        vault.deposit(initialDeposit);

        vm.stopPrank();

        assertEq(address(vault.token()), address(mockToken));
        assertEq(vault.balanceOf(depositor), initialDeposit);
        assertEq(mockToken.balanceOf(depositor), 0);
    }
}
