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
    address public firstDepositor = address(1);
    address public secondDepositor = address(2);

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
        mockToken.mint(firstDepositor, initialDeposit);

        vm.startPrank(firstDepositor);

        mockToken.approve(address(vault), initialDeposit);
        vault.deposit(initialDeposit);

        vm.stopPrank();

        assertEq(vault.balanceOf(firstDepositor), initialDeposit);
        assertEq(mockToken.balanceOf(firstDepositor), 0);
        assertEq(mockToken.balanceOf(address(vault)), initialDeposit);
    }

    function testSubsequentDeposit() public {
        uint256 initialDeposit = 1000;
        mockToken.mint(firstDepositor, initialDeposit);

        vm.startPrank(firstDepositor);

        mockToken.approve(address(vault), initialDeposit);
        vault.deposit(initialDeposit);

        vm.stopPrank();

        uint256 secondDeposit = 2000;
        mockToken.mint(secondDepositor, secondDeposit);

        vm.startPrank(secondDepositor);

        mockToken.approve(address(vault), secondDeposit);
        vault.deposit(secondDeposit);

        vm.stopPrank();

        assertEq(vault.balanceOf(firstDepositor), initialDeposit);
        assertEq(vault.balanceOf(secondDepositor), secondDeposit);
        assertEq(mockToken.balanceOf(firstDepositor), 0);
        assertEq(mockToken.balanceOf(secondDepositor), 0);
        assertEq(mockToken.balanceOf(address(vault)), initialDeposit + secondDeposit);
    }
}
