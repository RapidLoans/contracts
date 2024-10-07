// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/ITRC20.sol";

/**
 * @title LiquidityPool.
 * @author RapidLoans.
 * @notice A liquidity pool for Rapidloans to issue flash loans from.
 * @dev Token pair used currently is TRX/JST.
 */

contract LiquidityPool {
    struct Investor {
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
    event TRXWithdrawn(address investor, uint256 amountTRX);
    event JSTWithdrawn(address investor, uint256 amountJST);
    event BorrowedTRX(address borrower, uint256 amountTRX);
    event BorrowedJST(address borrower, uint256 amountJST);

    ITRC20 public jst = ITRC20(address(0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA));

    address public RAPID_LOANS_CORE;
    uint256 public BORROW_RATE = 6; // The rate of interest on borrowed funds
    uint256 public profitFromFlashLoansTRX;
    uint256 public profitFromFlashLoansJST;
    Investor[] internal investors;
    uint256 internal investorIdCounter;
    mapping(address => uint256) internal investorIndexes;

    constructor() {
        investorIdCounter = 1;
        Investor memory initialInvestor = Investor({
            investorId: 0,
            investor: address(0),
            balanceTRX: 0,
            balanceJST: 0
        });
        investors.push(initialInvestor);
    }

    function setRapidLoansCoreAddress(address rapidLoansCore) external {
        RAPID_LOANS_CORE = rapidLoansCore;
    }

    function addTRX() external payable returns (uint256 balanceTRX) {
        require(msg.value > 0, "Invalid amount");
        if (investorIndexes[msg.sender] == 0) {
            Investor memory temp = Investor({
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

    function addJST(uint256 amount) external returns (uint256 balanceJST) {
        require(
            jst.allowance(msg.sender, address(this)) > 0,
            "Not enough JST approved"
        );
        bool success = jst.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer of JST failed");
        if (investorIndexes[msg.sender] == 0) {
            Investor memory temp = Investor({
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

    function withdrawTRX(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(investors[investorIndexes[msg.sender]].balanceTRX >= amount, "Insufficient TRX balance");
        
        investors[investorIndexes[msg.sender]].balanceTRX -= amount;
        payable(msg.sender).transfer(amount);
        emit TRXWithdrawn(msg.sender, amount);
    }

    function withdrawJST(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(investors[investorIndexes[msg.sender]].balanceJST >= amount, "Insufficient JST balance");

        investors[investorIndexes[msg.sender]].balanceJST -= amount;
        bool success = jst.transfer(msg.sender, amount);
        require(success, "Transfer of JST failed");
        emit JSTWithdrawn(msg.sender, amount);
    }

    function borrowTRX(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(investors[investorIndexes[msg.sender]].balanceTRX >= amount, "Insufficient TRX balance");

        // Logic to charge interest could be added here
        investors[investorIndexes[msg.sender]].balanceTRX -= amount;
        payable(msg.sender).transfer(amount);
        emit BorrowedTRX(msg.sender, amount);
    }

    function borrowJST(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(investors[investorIndexes[msg.sender]].balanceJST >= amount, "Insufficient JST balance");

        // Logic to charge interest could be added here
        investors[investorIndexes[msg.sender]].balanceJST -= amount;
        bool success = jst.transfer(msg.sender, amount);
        require(success, "Transfer of JST failed");
        emit BorrowedJST(msg.sender, amount);
    }

    function WithdrawFlashLoanTRX(
        address payable subject,
        uint256 amount
    ) external returns (uint256 amountTRXWithdrawn) {
        require(address(this).balance > 0, "Not enough TRX in pool");
        require(amount > 0, "Invalid amount");
        bool success = payable(subject).send(amount);
        require(success, "Transfer to Subject failed");
        emit FlashLoanTRXWithdrawn(amount);
        return amount;
    }

    function WithdrawFlashLoanJST(
        address subject,
        uint256 amount
    ) external returns (uint256 amountJSTWithdrawn) {
        require(jst.balanceOf(address(this)) > 0, "Not enough JST in pool");
        require(amount > 0, "Invalid amount");
        jst.approve(subject, amount);
        bool success = jst.transfer(subject, amount);
        require(success, "Transfer to Subject failed");
        emit FlashLoanJSTWithdrawn(amount);
        return amount;
    }

    function getInvestorStruct(
        address investorAddress
    ) public view returns (Investor memory investorStruct) {
        return investors[investorIndexes[investorAddress]];
    }

    function getContractTRXBalance() public view returns (uint256 amountTRX) {
        return address(this).balance;
    }

    function getContractJSTBalance() public view returns (uint256 amountJST) {
        return jst.balanceOf(address(this));
    }

    function getUserTRXBalance(
        address investorAddress
    ) public view returns (uint256 amountTRX) {
        return investors[investorIndexes[investorAddress]].balanceTRX;
    }

    function getUserJSTBalance(
        address investorAddress
    ) public view returns (uint256 amountJST) {
        return investors[investorIndexes[investorAddress]].balanceJST;
    }

    receive() external payable {
        profitFromFlashLoansJST += msg.value;
    }
}
