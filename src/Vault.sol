// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import 'openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { UD60x18, ud } from "prb-math/UD60x18.sol";

contract Vault is ERC20("VLTS", "VaultShares") {
    IERC20 public immutable token;
    address public feeCollector;
    uint public feePercentage;

    constructor(address _token, address _feeCollector, uint _feePercentage) {
        token = IERC20(_token);
        feeCollector = _feeCollector;
        feePercentage = _feePercentage;
    }

    function deposit(uint _amount) external {
        /*
        a = amount of token to deposit
        B = balance of tokens in the vault before deposit
        T = total supply of shares
        s = shares to mint

        Balance of shares to mint (compared to total shares) 
        are proportional to the amount of tokens to deposit (compared to total amount of tokens in the vault)

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint shares;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply()) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _shares) external {
        /*
        a = amount of token to receive
        B = balance of tokens in the vault before withdraw
        T = total supply of shares
        s = shares to withdraw

        Balance of shares to withdraw (compared to total shares) 
        are proportional to the amount of tokens to receive (compared to total amount of tokens in the vault)

        (T - s) / T = (B - a) / B 

        a = sB / T

        Then the fee is deducted and the fee is sent to a dedicated address
        Otherwise the retained fee would invalidate the proportional calculations
        */
        uint amountWithFee = (_shares * token.balanceOf(address(this))) / totalSupply();

        UD60x18 feePercent = ud(feePercentage);
        uint256 fee = UD60x18.unwrap(ud(amountWithFee).mul(feePercent));
        uint amount = amountWithFee - fee;

        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
        token.transfer(feeCollector, fee);
    }
}

