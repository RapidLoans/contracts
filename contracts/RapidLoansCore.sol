// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./LiquidityPool.sol";
import "./interfaces/IReceiverContract.sol";
import "./interfaces/ITRC20.sol";

contract RapidLoansCore {
    ITRC20 public jst =
        ITRC20(address(0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA));
    LiquidityPool public liquidityPool;
    uint256 public FEE = 5;

    constructor(address _liquidityPool) {
        liquidityPool = LiquidityPool(payable(_liquidityPool));
    }

    function requestFlashLoanTRX(
        uint256 _amount,
        address payable subject
    ) public returns (uint256 amountWithdrawn) {
        uint256 amountTRXWithdrawn = liquidityPool.WithdrawFlashLoanTRX(
            subject,
            _amount
        );
        require(amountTRXWithdrawn > 0, "Transfer to subject failed");
        uint256 initialAmount = address(this).balance;
        IReceiverContract(subject).executeTRXRapidLoan(_amount + FEE);
        uint256 finalAmount = address(this).balance;
        require(finalAmount > initialAmount, "loan not returned you cheap");
        (bool success, ) = payable(address(liquidityPool)).call{
            value: address(this).balance
        }("");
        require(success, "Transfer to liquidityPool failed");
        return amountTRXWithdrawn;
    }

    function requestFlashLoanJST(
        uint256 _amount,
        address subject
    ) public returns (uint256) {
        uint256 amountJSTWithdrawn = liquidityPool.WithdrawFlashLoanJST(
            subject,
            _amount
        );
        require(amountJSTWithdrawn > 0, "Transfer to subject failed");
        uint256 initialAmount = jst.balanceOf(address(this));
        IReceiverContract(subject).executeJSTRapidLoan(_amount + FEE);
        uint256 finalAmount = jst.balanceOf(address(this));
        require(
            finalAmount > initialAmount,
            "RapidLoansCore loan not returned you cheap"
        );
        bool success = jst.transferFrom(
            address(this),
            address(liquidityPool),
            _amount + FEE
        );
        require(success, "Transfer to liquidityPool failed");
        return amountJSTWithdrawn;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
