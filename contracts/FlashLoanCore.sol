// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./LiquidityPool.sol";
import "./interfaces/IReceiverContract.sol";

contract FlashLoanCore {
    LiquidityPool public lp;

    constructor(address _liquidityPool) {
        lp = LiquidityPool(payable(_liquidityPool));
    }

    function requestFlashLoanTRX(
        uint256 _amount,
        address payable _receiver
    ) public returns (bool) {
        // require(address(this).balance > 0, "Not enough TRX");
        bool success = lp.flashLoanTRX(payable(_receiver), _amount);
        // bool success = _receiver.send(_amount);
        // IReceiverContract(_receiver).executeRapidLoan();
        require(success, "transfer to recipient failed");
        uint256 initialAmount = address(this).balance;
        uint256 amountReturned = IReceiverContract(_receiver)
            .executeRapidLoan();
        uint256 finalAmount = address(this).balance;
        require(finalAmount > initialAmount, "loan not returned you cheap");
        return success;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
