// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./LiquidityPool.sol";
import "./interfaces/IReceiverContract.sol";
import "./interfaces/ITRC20.sol";

/**
 * @title RapidLoansCore.
 * @author RapidLoans
 * @notice Contract that the customer contract calls to initiate TRX or JST flash loans without collateral.
 * @notice Always remember, if you do not pay back the principle amount + fee, the whole transaction will revert to the initial state.
 */
contract RapidLoansCore {
    address public JST_CONTRACT_ADDRESS_NILE =
        0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA;
    ITRC20 public jst = ITRC20(JST_CONTRACT_ADDRESS_NILE);
    LiquidityPool public liquidityPool;
    /**
     * @notice Fee percentage of flash loans.
     */
    uint256 public FLASH_LOAN_FEE_PERCENT = 5;

    constructor(address _liquidityPool) {
        liquidityPool = LiquidityPool(payable(_liquidityPool));
    }

    /**
     * @notice Request TRX for flash loan, called by customer contract.
     * @notice This functions also calls executeRapidLoan function of customer contract
     * that contains the flash loan execution logic.
     * @notice This functions also ensures that loan is paid back with premium(decided by governance), if not,
     * the whole transaction reverts to the initial state like no funds were sent.
     * @param _amount Amount of TRX requested by the customer.
     * @param subject Contract address of the flash loan receiver contract(customer contract).
     * @return amountWithdrawn Amount of TRX withdrawn for the flash loan from liquidity pool.
     */
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
        uint256 premium = (_amount * FLASH_LOAN_FEE_PERCENT) / 100;
        IReceiverContract(subject).executeTRXRapidLoan(_amount + premium);
        uint256 finalAmount = address(this).balance;
        require(finalAmount > initialAmount, "loan not returned you cheap");
        (bool success, ) = payable(address(liquidityPool)).call{
            value: address(this).balance
        }("");
        require(success, "Transfer to liquidityPool failed");
        return amountTRXWithdrawn;
    }

    /**
     * @notice Request JST for flash loan, called by customer contract.
     * @notice This functions also calls executeRapidLoan function of customer contract.
     * @notice This functions also ensures that loan is paid back with fee(determined by governance), if not,
     * the whole transaction reverts to the initial state like no funds were sent.
     * @param _amount Amount of TRX requested by the customer.
     * @param subject Address of the flash loan receiver contract(customer contract).
     * @return amountJSTWithdrawn Amount of JST withdrawn for the flash loan from liquidity pool.
     */
    function requestFlashLoanJST(
        uint256 _amount,
        address payable subject
    ) public returns (uint256 amountJSTWithdrawn) {
        amountJSTWithdrawn = liquidityPool.WithdrawFlashLoanJST(
            address(this),
            _amount
        );
        require(amountJSTWithdrawn > 0, "Transfer to subject failed");
        uint256 initialAmount = jst.balanceOf(address(this));
        IReceiverContract(subject).executeJSTRapidLoan(
            jst.balanceOf(address(this))
        );
        uint256 finalAmount = jst.balanceOf(address(this));
        require(
            finalAmount > initialAmount,
            "RapidLoansCore loan not returned you cheap"
        );
        bool success = jst.transfer(
            address(liquidityPool),
            _amount + FLASH_LOAN_FEE_PERCENT
        );
        require(success, "Transfer to liquidityPool failed");
        return amountJSTWithdrawn;
    }

    /**
     * @return balance in TRX of this contract.
     */
    function getContractBalance() public view returns (uint256 balance) {
        return address(this).balance;
    }

    /**
     * @notice A simple function that allows external addresses to send TRX to this contract.
     */
    receive() external payable {}
}
