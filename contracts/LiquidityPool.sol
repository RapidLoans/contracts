// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./interfaces/ITRC20.sol";
import "./PriceOracle.sol";

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
        uint256 lastInvestedTRXTimestamp;
        uint256 lastInvestedJSTTimestamp;
        uint256 borrowedTRX;
        uint256 borrowedJST;
    }
    event NewInvestor(address investor);
    event JSTAdded(address investor, uint256 amountJST);
    event TRXAdded(address investor, uint256 amountTRX);
    event FlashLoanTRXWithdrawn(uint256 amountTRX);
    event FlashLoanJSTWithdrawn(uint256 amountJST);
    event TRXWithdrawn(address investor, uint256 amountTRX);
    event JSTWithdrawn(address investor, uint256 amountJST);
    event BorrowedTRX(address borrower, uint256 amountTRX);
    event BorrowedJST(address borrower, uint256 amountJST);
    event RepiadTRX(address borrower, uint256 amountRepaidWithIntrest);

    address public RAPID_LOANS_CORE;
    address public JST_CONTRACT_ADDRESS_NILE =
        0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA;
    ITRC20 public jst = ITRC20(JST_CONTRACT_ADDRESS_NILE);
    PriceOracle public priceOracle;

    /**
     * @notice Borrow rate for liquidity pool loans determined by governance, NOT FLASH LOANS.
     */
    uint256 public PROFIT_RATE = 6;
    uint256 public BORROW_RATE = 7;
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

    constructor(address _priceOracle) {
        priceOracle = PriceOracle(_priceOracle);
        investorIdCounter = 1;
        investor memory initialInvestor = investor({
            investorId: 0,
            investor: address(0),
            balanceTRX: 0,
            balanceJST: 0,
            lastInvestedTRXTimestamp: block.timestamp,
            lastInvestedJSTTimestamp: block.timestamp,
            borrowedTRX: 0,
            borrowedJST: 0
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
     * @notice User can invest only once in 15 days.
     * @dev Creates a new vault if new user or updates the balance, sets block.timestamp to current.
     * @return balanceTRX Amount added.
     */
    function addTRX() external payable returns (uint256 balanceTRX) {
        require(msg.value > 0, "Invalid amount");
        require(
            block.timestamp >=
                investors[investorIndexes[msg.sender]]
                    .lastInvestedTRXTimestamp +
                    15 days,
            "User already invested"
        );
        if (investorIndexes[msg.sender] == 0) {
            investor memory temp = investor({
                investorId: investorIdCounter,
                investor: msg.sender,
                balanceTRX: msg.value,
                balanceJST: 0,
                lastInvestedTRXTimestamp: block.timestamp,
                lastInvestedJSTTimestamp: block.timestamp,
                borrowedTRX: 0,
                borrowedJST: 0
            });
            investors.push(temp);
            investorIndexes[msg.sender] = investorIdCounter;
            investorIdCounter++;
            emit NewInvestor(msg.sender);

            return investors[investorIndexes[msg.sender]].balanceTRX;
        } else {
            investors[investorIndexes[msg.sender]].balanceTRX += msg.value;
            investors[investorIndexes[msg.sender]]
                .lastInvestedTRXTimestamp = block.timestamp;
        }
        emit TRXAdded(msg.sender, msg.value);
    }

    /**
     * @notice Function to add JST to the liquidity pool, as an investment to earn APY.
     * @notice You need to approve JST, this contract as the spender, amount same as param.
     * @notice User can invest only once in 15 days.
     * @dev Creates a new vault if new user or updates the balance, sets block.timestamp to current.
     * @param amount Amount to invest.
     * @return balanceJST Amount added.
     */
    function addJST(uint256 amount) external returns (uint256 balanceJST) {
        require(
            jst.allowance(msg.sender, address(this)) > 0,
            "Not enough JST approved"
        );
        require(
            block.timestamp >=
                investors[investorIndexes[msg.sender]]
                    .lastInvestedJSTTimestamp +
                    15 days,
            "User already invested"
        );
        bool success = jst.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer of JST failed");
        if (investorIndexes[msg.sender] == 0) {
            investor memory temp = investor({
                investorId: investorIdCounter,
                investor: msg.sender,
                balanceTRX: 0,
                balanceJST: amount,
                lastInvestedTRXTimestamp: block.timestamp,
                lastInvestedJSTTimestamp: block.timestamp,
                borrowedTRX: 0,
                borrowedJST: 0
            });
            investors.push(temp);
            investorIndexes[msg.sender] = investorIdCounter;
            investorIdCounter++;
            emit NewInvestor(msg.sender);
        } else {
            investors[investorIndexes[msg.sender]].balanceJST += amount;
            investors[investorIndexes[msg.sender]]
                .lastInvestedJSTTimestamp = block.timestamp;
        }
        emit JSTAdded(msg.sender, amount);
        return investors[investorIndexes[msg.sender]].balanceJST;
    }

    /**
     * @notice Withdraw TRX from the liquidity pool, including intrest for one month.
     * @notice Investment must be made 15 days prior to withdrawal.
     * @param amount Amount of TRX to withdraw.
     */
    function withdrawTRX(
        uint256 amount
    ) external returns (uint256 amountWithdrawnTRX) {
        require(amount > 0, "Invalid amount");
        require(
            investors[investorIndexes[msg.sender]].balanceTRX == amount,
            "Enter full amount"
        );
        require(
            block.timestamp >=
                investors[investorIndexes[msg.sender]]
                    .lastInvestedJSTTimestamp +
                    15 days,
            "Amount locked for 15 days"
        );
        investors[investorIndexes[msg.sender]].balanceTRX -= amount;
        uint256 finalAmount = ((PROFIT_RATE * amount) / 100) + (amount);
        payable(msg.sender).transfer(finalAmount);
        emit TRXWithdrawn(msg.sender, amount);
        return amount;
    }

    /**
     * @notice Withdraw JST from the liquidity pool, including intrest for one month.
     * @notice Investment must be made 15 days prior to withdrawal.
     * @param amount Amount of JST to withdraw.
     */
    function withdrawJST(
        uint256 amount
    ) external returns (uint256 amountWithdrawnJST) {
        require(amount > 0, "Invalid amount");
        require(
            investors[investorIndexes[msg.sender]].balanceJST == amount,
            "Enter full amount"
        );
        require(
            block.timestamp >=
                investors[investorIndexes[msg.sender]]
                    .lastInvestedJSTTimestamp +
                    15 days,
            "Amount is locked for 15 days"
        );
        investors[investorIndexes[msg.sender]].balanceJST -= amount;
        uint256 finalAmount = ((PROFIT_RATE * amount) / 100) + (amount);
        bool success = jst.transferFrom(address(this), msg.sender, finalAmount);
        require(success, "Transfer of JST failed");
        emit JSTWithdrawn(msg.sender, amount);
        return amount;
    }

    /**
     * @notice Borrow TRX from the liquidity pool.
     * @notice You must have equal JST tokens invested to borrow TRX.
     * @notice While repaying the loan, you are charged intrest of one month, this is a one month only loan.
     * @param amount Amount of TRX to borrow.
     */
    function borrowTRX(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(
            investors[investorIndexes[msg.sender]].balanceJST >=
                priceOracle.getTRXToJST(amount),
            "Insufficient JST balance"
        );
        uint256 amountToBeDeducted = priceOracle.getTRXToJST(amount);
        investors[investorIndexes[msg.sender]].balanceJST -= amountToBeDeducted;
        bool success = payable(msg.sender).send(amount);
        require(success, "Transfer of TRX failed");
        emit BorrowedTRX(msg.sender, amount);
    }

    /**
     * @notice Repay TRX debt to liquidity pool.
     * @notice You must have an outstanding debt.
     * @notice Msg.value must be greater than principal + intrest.
     */
    function repayTRX() external payable {
        require(msg.value > 0, "Invalid amount");
        uint256 borrowedAmount = investors[investorIndexes[msg.sender]]
            .borrowedTRX;
        uint256 finalAmount = ((BORROW_RATE * borrowedAmount) / 100) +
            (borrowedAmount);
        require(msg.value >= finalAmount, "Repay the whole loan.");
        investors[investorIndexes[msg.sender]].balanceTRX -= msg.value;
        emit RepiadTRX(msg.sender, msg.value);
    }

    /**
     * @notice Borrow JST from the liquidity pool.
     * @notice You must have equal TRX tokens invested to borrow JST.
     * @notice While repaying the loan, you are charged intrest of one month, this is a one month only loan.
     * @param amount Amount of JST to borrow.
     */
    function borrowJST(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(
            investors[investorIndexes[msg.sender]].balanceTRX >=
                priceOracle.getJSTToTRX(amount),
            "Insufficient TRX balance"
        );
        uint256 amountToBeDeducted = priceOracle.getJSTToTRX(amount);
        investors[investorIndexes[msg.sender]].balanceTRX -= amountToBeDeducted;
        investors[investorIndexes[msg.sender]].balanceJST -= amount;
        bool success = jst.transfer(msg.sender, amount);
        require(success, "Transfer of JST failed");
        emit BorrowedJST(msg.sender, amount);
    }

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
     * @param investorAddress Address of the investor.
     * @return timestamp The timestamp of the last time the investor invested TRX.
     */
    function getUserLastInvestedTRXTimestamp(
        address investorAddress
    ) public view returns (uint256 timestamp) {
        return
            investors[investorIndexes[investorAddress]]
                .lastInvestedTRXTimestamp;
    }

    /**
     * @param investorAddress Address of the investor.
     * @return timestamp The timestamp of the last time the investor invested JST.
     */
    function getUserLastInvestedJSTTimestamp(
        address investorAddress
    ) public view returns (uint256 timestamp) {
        return
            investors[investorIndexes[investorAddress]]
                .lastInvestedJSTTimestamp;
    }

    /**
     * @param investorAddress Address of the investor.
     * @return Timestamp of time left in which user can withdraw its investment including profit earned.
     */
    function getUserTRXInvestmentWithdrawTime(
        address investorAddress
    ) public view returns (uint256) {
        if (investorIndexes[investorAddress] == 0) {
            return 0;
        } else {
            if (
                investors[investorIndexes[investorAddress]]
                    .lastInvestedTRXTimestamp +
                    15 days >
                block.timestamp
            ) {
                return 0;
            } else {
                return
                    investors[investorIndexes[investorAddress]]
                        .lastInvestedTRXTimestamp +
                    15 days -
                    block.timestamp;
            }
        }
    }

    /**
     * @param investorAddress Address of the investor.
     * @return Timestamp of time left in which user can withdraw its investment including profit earned.
     */
    function getUserJSTInvestmentWithdrawTime(
        address investorAddress
    ) public view returns (uint256) {
        if (investorIndexes[investorAddress] == 0) {
            return 0;
        } else {
            if (
                investors[investorIndexes[investorAddress]]
                    .lastInvestedJSTTimestamp +
                    15 days >
                block.timestamp
            ) {
                return 0;
            } else {
                return
                    investors[investorIndexes[investorAddress]]
                        .lastInvestedJSTTimestamp +
                    15 days -
                    block.timestamp;
            }
        }
    }

    /**
     * @dev Receive function to receive TRX from any address.
     */
    receive() external payable {
        profitFromFlashLoansJST += msg.value;
    }
}
