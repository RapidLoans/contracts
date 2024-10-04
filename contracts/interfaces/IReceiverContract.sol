// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReceiverContract {
    function executeRapidLoan() external returns (uint256 loanReturnValue);
}
