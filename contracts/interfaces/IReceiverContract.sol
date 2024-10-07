// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @title IReceiverContract.
 * @author RapidLoans.
 * @notice A simple interface which customer contract needs to inherit and override its functions.
 * @notice Overriding functions can execute logic for flash loans, whatever the customer wants to do .
 * @notice In the overriding functions, the customer has to repay the loan with the fee
 * (determined by governanace)or else, the entire transaction will revert to the initial state.
 */
interface IReceiverContract {
    /**
     * @notice Custom logic for received TRX flash loans + Sending back the funds with fee.
     * @notice This function is called by RapidLoansCore when user requests a flash loan.
     * @param _returnAmount Amount of TRX paid back, including the fee.
     */
    function executeTRXRapidLoan(uint256 _returnAmount) external returns (bool);

    /**
     * @notice Custom logic for received JST flash loans + Sending back the funds with fee.
     * @notice This function is called by RapidLoansCore when user requests a flash loan.
     * @param _returnAmount Amount of JST paid back, including the fee.
     */
    function executeJSTRapidLoan(uint256 _returnAmount) external returns (bool);
}
