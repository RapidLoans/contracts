// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IReceiverContract {
    function executeTRXRapidLoan(uint256 _returnAmount) external returns (bool);

    function executeJSTRapidLoan(uint256 _returnAmount) external returns (bool);
}
