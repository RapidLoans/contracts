// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import "../interfaces/IReceiverContract.sol";
import "../RapidLoansCore.sol";

contract Subject is IReceiverContract {
    ITRC20 public jst =
        ITRC20(address(0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA));
    RapidLoansCore public flashLoanCore;

    constructor(address payable _flashLoanCore) {
        flashLoanCore = RapidLoansCore(_flashLoanCore);
    }

    function requestFlashLoanTRX(
        uint256 _amount
    ) public payable returns (uint256) {
        uint256 amountReceived = flashLoanCore.requestFlashLoanTRX(
            _amount,
            payable(address(this))
        );

        return amountReceived;
    }

    function requestFlashLoanJST(
        uint256 _amount
    ) public payable returns (uint256) {
        uint256 amountReceived = flashLoanCore.requestFlashLoanJST(
            _amount,
            payable(address(this))
        );

        return amountReceived;
    }

    function executeTRXRapidLoan(
        uint256 _repayAmount
    ) external override returns (bool) {
        //arbitrage
        bool success = payable(address(flashLoanCore)).send(_repayAmount);
        return success;
    }

    function executeJSTRapidLoan(
        uint256 _repayAmount
    ) external override returns (bool) {
        jst.approve(address(flashLoanCore), _repayAmount);
        bool success = jst.transfer(address(flashLoanCore), _repayAmount);
        require(success, "Failed to repay loan");
    }

    function getContractBalance() public returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
