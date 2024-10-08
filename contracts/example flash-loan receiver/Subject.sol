// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "../interfaces/IReceiverContract.sol";
import "../RapidLoansCore.sol";

/**
 * @title Subject.
 * @author RapidLoans.
 * @notice An example customer contract for executing RapidLoans flash loans taking advantage of arbitrage,etc.
 */
contract Subject is IReceiverContract {
    address public JST_CONTRACT_ADDRESS_NILE =
        0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA;
    ITRC20 public jst = ITRC20(JST_CONTRACT_ADDRESS_NILE);
    RapidLoansCore public flashLoanCore;

    constructor(address payable _flashLoanCore) {
        flashLoanCore = RapidLoansCore(_flashLoanCore);
    }

    /**
     * @notice Initiate a flash loan for TRX.
     * @notice Before calling this function, make sure that executeTRXRapidLoan has the appropriate
     * logic to execute the flash loan, transferring back the principal amount + fee.
     * @param _amount Amount of TRX requested by the customer.
     * @return amountReceived Amount of TRX received by this contract.
     */
    function requestFlashLoanTRX(
        uint256 _amount
    ) public returns (uint256 amountReceived) {
        amountReceived = flashLoanCore.requestFlashLoanTRX(
            _amount,
            payable(address(this))
        );

        return amountReceived;
    }

    /**
     * @notice Initiate a flash loan for JST.
     * @notice Before calling this function, make sure that executeJSTRapidLoan has the appropriate
     * logic to execute the flash loan, transferring back the principal amount + fee.
     * @param _amount Amount of JST requested by the customer.
     * @return amountReceived Amount of JST received by this contract.
     */
    function requestFlashLoanJST(
        uint256 _amount
    ) public returns (uint256 amountReceived) {
        amountReceived = flashLoanCore.requestFlashLoanJST(
            _amount,
            payable(address(this))
        );

        return amountReceived;
    }

    /**
     * @notice Function that contains the "what to do with the flash loan that i just requested" logic.
     * @notice This function is only called by RapidLoansCore contract.
     * @param _repayAmount Principal amount + fee to be repaid in TRX, given by the RapodLoansCore contract.
     * @return success If the flash loan was successfully executed.
     */
    function executeTRXRapidLoan(
        uint256 _repayAmount
    ) external override returns (bool success) {
        //arbitrage logic

        success = payable(address(flashLoanCore)).send(_repayAmount);
        return success;
    }

    /**
     * @notice Function that contains the "what to do with the flash loan that i just requested" logic.
     * @notice This function is only called by RapidLoansCore contract.
     * @param _repayAmount Principal amount + fee to be repaid in JST, given by the RapodLoansCore contract.
     * @return success If the flash loan was successfully executed.
     */
    function executeJSTRapidLoan(
        uint256 _repayAmount
    ) external override returns (bool success) {
        jst.approve(address(flashLoanCore), _repayAmount);
        success = jst.transfer(address(flashLoanCore), _repayAmount);
        require(success, "Failed to repay loan");
    }

    /**
     * @return balance in TRX of this contract.
     */
    function getContractBalance() public view returns (uint256 balance) {
        return address(this).balance;
    }

    function getFlashLoanCoreAddress() public view returns (address) {
        return address(flashLoanCore);
    }

    function test() public payable {}

    /**
     * @notice A simple function that allows external addresses to send TRX to this contract.
     */
    receive() external payable {}
}
