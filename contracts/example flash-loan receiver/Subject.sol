// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "../interfaces/IReceiverContract.sol";
import "../FlashLoanCore.sol";

contract Subject is IReceiverContract {
    FlashLoanCore public flashLoanCore;

    constructor(address payable _flashLoanCore) {
        flashLoanCore = FlashLoanCore(_flashLoanCore);
    }

    function requestFlashLoanTRX() public returns (bool) {
        flashLoanCore.requestFlashLoanTRX(2, payable(address(this)));
    }

    function executeRapidLoan() external override returns (uint256) {
        bool success = payable(address(flashLoanCore)).send(3);
        return 3;
    }

    receive() external payable {}
}
