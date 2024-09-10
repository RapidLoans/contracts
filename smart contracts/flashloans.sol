// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Interface for token standards (USDT, TRX, etc.)

contract FlashLoan {
    address public pool;
    uint256 public feePercentage = 1; // 1% fee for the flash loan

    constructor(address _pool) {
        pool = _pool;
    }

    // Function to request a flash loan
    function flashLoan(
        address _token,
        uint256 _amount,
        address _dex
    ) external {
        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
        require(balanceBefore >= _amount, "Insufficient liquidity in pool");

        // Transfer tokens to borrower
        IERC20(_token).transfer(msg.sender, _amount);

        // Let borrower execute their logic via a callback function
        (bool success, ) = _dex.call(
            abi.encodeWithSignature("executeFlashLoan(address,uint256)", _token, _amount)
        );
        require(success, "Dex transaction failed");

        // Collect the loan back with the fee
        uint256 fee = (_amount * feePercentage) / 100;
        uint256 totalRepayment = _amount + fee;

        require(
            IERC20(_token).balanceOf(address(this)) >= totalRepayment,
            "Loan wasn't repaid properly"
        );
    }

    // Update pool address
    function updatePool(address _newPool) external {
        pool = _newPool;
    }

    // Update fee percentage
    function updateFee(uint256 _newFeePercentage) external {
        feePercentage = _newFeePercentage;
    }
}
