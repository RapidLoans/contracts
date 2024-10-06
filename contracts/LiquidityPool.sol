// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./interfaces/ITRC20.sol";

/**
 * @title LiquidityPool.
 * @author RapidLoans.
 * @notice A liquidity pool for Rapidloans to issue flash loans from.
 * @notice You get annual apy of 6% to invest any of the two tokens and this rate is determined by governance.
 * @dev Token pair used currently is TRX/JST.
 */

contract LiquidityPool {
    /**
     * @notice Struct for storing investor data.
     */
    struct investor {
        uint256 investorId;
        address investor;
        uint256 balanceTRX;
        uint256 balanceJST;
    }

    event NewInvestor(address investor);
    event JSTAdded(address investor, uint256 amountJST);
    event TRXAdded(address investor, uint256 amountTRX);
    event FlashLoanTRXWithdrawn(uint256 amountTRX);
    event FlashLoanJSTWithdrawn(uint256 amountJST);

    address public RAPID_LOANS_CORE;
    address public JST_CONTRACT_ADDRESS_NILE =
        0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA;
    ITRC20 public jst = ITRC20(JST_CONTRACT_ADDRESS_NILE);

    /**
     * @notice Borrow rate for liquidity pool loans determined by governance, NOT FLASH LOANS.
     */
    uint256 public BORROW_RATE = 6;
    uint256 public profitFromFlashLoansTRX;
    uint256 public profitFromFlashLoansJST;
    /**
     * @dev Array of investor structs.
     */
    investor[] internal investors;
    /**
     * @dev Counter for investor ids, index in the array.
     */
    uint256 internal investorIdCounter;
    /**
     * @dev Mapping from investor address to index in the array.
     */
    mapping(address => uint256) internal investorIndexes;

    constructor() {
        investorIdCounter = 1;
        investor memory initialInvestor = investor({
            investorId: 0,
            investor: address(0),
            balanceTRX: 0,
            balanceJST: 0
        });
        investors.push(initialInvestor);
    }

    /**
     * @notice Set the address of the RapidLoansCore contract.
     * @param rapidLoansCore Address.
     */
    function setRapidLoansCoreAddress(address rapidLoansCore) external {
        RAPID_LOANS_CORE = rapidLoansCore;
    }

    /**
     * @notice Function to add TRX to the liquidity pool, as an investment to earn APY.
     * @dev Creates a new vault if new user or updates the balance.
     * @return balanceTRX Amount added.
     */
    function addTRX() external payable returns (uint256 balanceTRX) {
        require(msg.value > 0, "Invalid amount");
        if (investorIndexes[msg.sender] == 0) {
            investor memory temp = investor({
                investorId: investorIdCounter,
                investor: msg.sender,
                balanceTRX: msg.value,
                balanceJST: 0
            });
            investors.push(temp);
            investorIndexes[msg.sender] = investorIdCounter;
            investorIdCounter++;
            emit NewInvestor(msg.sender);
        } else {
            investors[investorIndexes[msg.sender]].balanceTRX += msg.value;
        }
        emit TRXAdded(msg.sender, msg.value);
        return investors[investorIndexes[msg.sender]].balanceTRX;
    }

    /**
     * @notice Function to add JST to the liquidity pool, as an investment to earn APY.
     * @notice You need to approve JST, this contract as the spender, amount same as param.
     * @dev Creates a new vault if new user or updates the balance.
     * @param amount Amount to invest.
     * @return balanceJST Amount added.
     */
    function addJST(uint256 amount) external returns (uint256 balanceJST) {
        require(
            jst.allowance(msg.sender, address(this)) > 0,
            "Not enough JST approved"
        );
        bool success = jst.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer of JST failed");
        if (investorIndexes[msg.sender] == 0) {
            investor memory temp = investor({
                investorId: investorIdCounter,
                investor: msg.sender,
                balanceTRX: 0,
                balanceJST: amount
            });
            investors.push(temp);
            investorIndexes[msg.sender] = investorIdCounter;
            investorIdCounter++;
            emit NewInvestor(msg.sender);
        } else {
            investors[investorIndexes[msg.sender]].balanceJST += amount;
        }
        emit JSTAdded(msg.sender, amount);
        return investors[investorIndexes[msg.sender]].balanceJST;
    }

    function withdrawTRX(uint256 amount) external {}

    function withdrawJST(uint256 amount) external {}

    function borrowTRX(uint256 amount) external {}

    function borrowJST(uint256 amount) external {}

    /**
     * @notice Withdraw TRX from the liquidity pool for a flash loan.
     * @notice Customer contract sends back some extra TRX as a fee to liquidity pool.
     * @dev Only the RapidLoansCore contract can call this function.
     * @param subject Contract address of the flash loan receiver contract(customer contract).
     * @param amount Amount of TRX flash loan requested by the user.
     * @return amountTRXWithdrawn Amount in TRX withdrawn from liquidity pool.
     */
    function WithdrawFlashLoanTRX(
        address payable subject,
        uint256 amount
    ) external returns (uint256 amountTRXWithdrawn) {
        require(address(this).balance > 0, "Not enough TRX in pool");
        require(amount > 0, "Invalid amount");
        bool success = payable(subject).send(amount);
        require(success, "Transfer to Subject failed");
        // profitFromFlashLoansTRX += finalTRX - initialTRX;
        emit FlashLoanTRXWithdrawn(amount);
        return amount;
    }

    /**
     * @notice Withdraw JST from the liquidity pool for a flash loan.
     * @notice Customer contract sends back some extra JST as a fee to liquidity pool.
     * @dev Only the RapidLoansCore contract can call this function.
     * @param subject Contract address of the flash loan receiver contract(customer contract).
     * @param amount Amount of JST flash loan requested by the user.
     * @return amountJSTWithdrawn Amount in JST withdrawn from liquidity pool.
     */
    function WithdrawFlashLoanJST(
        address subject,
        uint256 amount
    ) external returns (uint256 amountJSTWithdrawn) {
        require(jst.balanceOf(address(this)) > 0, "Not enough JST in pool");
        require(amount > 0, "Invalid amount");
        jst.approve(subject, amount);
        bool success = jst.transfer(subject, amount);
        require(success, "Transfer to Subject failed");
        // profitFromFlashLoansJST += finalJST - initialJST;
        emit FlashLoanJSTWithdrawn(amount);
        return amount;
    }

    /**
     * @param investorAddress Address of the investor.
     * @return investorStruct Struct representing vault details of the investor.
     */
    function getInvestorStruct(
        address investorAddress
    ) public view returns (investor memory investorStruct) {
        return investors[investorIndexes[investorAddress]];
    }

    /**
     * @return amountTRX Returns the TRX balance of the contract.
     */
    function getContractTRXBalance() public view returns (uint256 amountTRX) {
        return address(this).balance;
    }

    /**
     * @return amountJST Returns the JST balance of the contract.
     */
    function getContractJSTBalance() public view returns (uint256 amountJST) {
        return jst.balanceOf(address(this));
    }

    /**
     * @param investorAddress Address of the investor.
     * @return amountTRX The TRX balance of the investor.
     */
    function getUserTRXBalance(
        address investorAddress
    ) public view returns (uint256 amountTRX) {
        return investors[investorIndexes[investorAddress]].balanceTRX;
    }

    /**
     * @param investorAddress Address of the investor.
     * @return amountJST The JST balance of the investor.
     */
    function getUserJSTBalance(
        address investorAddress
    ) public view returns (uint256 amountJST) {
        return investors[investorIndexes[investorAddress]].balanceJST;
    }

    /**
     * @dev Receive function to receive TRX from any address.
     */
    receive() external payable {
        profitFromFlashLoansJST += msg.value;
    }
}
