// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IRapidLoansCore {
    /**
     * @notice Request TRX for flash loan.
     * @notice Before calling this function make sure to inherit IReceiverContract in your contract
     * and override its executeTRXRapidLoan function, writing custom logic for received funds, eg
     * arbitrage.
     * @notice If not, the whole transaction will revert to the initial state like it never happened.
     * @param _amount Amount of TRX requested by the customer.
     * @param subject Contract address of the flash loan receiver contract (customer contract).
     * @return amountWithdrawn Amount of TRX withdrawn for the flash loan from the liquidity pool.
     */
    function requestFlashLoanTRX(
        uint256 _amount,
        address payable subject
    ) external returns (uint256 amountWithdrawn);

    /**
     * @notice Request JST for flash loan.
     * @notice Before calling this function make sure to inherit IReceiverContract in your contract
     * and override its executeJSTRapidLoan function, writing custom logic for received funds, eg
     * arbitrage.
     * @notice If not, the whole transaction will revert to the initial state like it never happened.
     * @param _amount Amount of JST requested by the customer.
     * @param subject Address of the flash loan receiver contract (customer contract).
     * @return amountJSTWithdrawn Amount of JST withdrawn for the flash loan from the liquidity pool.
     */
    function requestFlashLoanJST(
        uint256 _amount,
        address payable subject
    ) external returns (uint256 amountJSTWithdrawn);

    /**
     * @return balance in TRX of this contract.
     */
    function getContractBalance() external view returns (uint256 balance);

    /**
     * @notice A simple function that allows external addresses to send TRX to this contract.
     */
    receive() external payable;
}
