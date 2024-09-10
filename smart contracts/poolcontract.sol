// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Pool {
    address public token;

    constructor(address _token) {
        token = _token;
    }

    // Deposit tokens to the pool
    function deposit(uint256 _amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
    }

    // Withdraw tokens from the pool (for governance or admin only)
    function withdraw(uint256 _amount) external {
        // Require that only the owner can withdraw
        // You can add governance mechanism to authorize withdrawals
        IERC20(token).transfer(msg.sender, _amount);
    }

    // Get pool balance
    function getPoolBalance() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}
