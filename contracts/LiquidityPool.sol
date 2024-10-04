// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/ITRC20.sol";

/**
 * @title LendingPool.
 * @author RapidLoans.
 * @notice A lending pool for Rapidloans to issue flash loans from.
 * @dev Token pair used currently is TRX/JST.
 */

contract LiquidityPool {
    struct investor {
        uint256 investorId;
        address investor;
        uint256 balanceTRX;
        uint256 balanceJST;
    }

    ITRC20 public jst =
        ITRC20(address(0x37349aEB75a32f8c4c090DAFF376cF975F5d2eBA));
    investor[] internal investors;
    uint256 internal investorIdCounter;
    uint256 public BORROW_RATE = 6;

    mapping(address => uint256) internal investorIndexes;

    event NewInvestor(address);

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

    function addTRX() external payable returns (address) {
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
        return msg.sender;
    }

    function addJST(uint256 amount) external returns (address) {
        require(
            jst.allowance(msg.sender, address(this)) > 0,
            "Not enough approved"
        );
        jst.transferFrom(msg.sender, address(this), amount);
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
        return investors[investorIndexes[msg.sender]].investor;
    }

    function withdrawTRX(uint256 amount) external {}

    function withdrawJST(uint256 amount) external {}

    function borrowTRX(uint256 amount) external {}

    function borrowJST(uint256 amount) external {}

    function flashLoanTRX(
        address payable flashLoanCore,
        uint256 amount
    ) external returns (bool) /**Only FlashLoanCore */ {
        require(address(this).balance > 0, "Not enough TRX in pool");
        require(amount > 0, "Invalid amount");
        bool success = flashLoanCore.send(amount);
        require(success, "Transfer failed");
        return success;
    }

    function flashLoanJST(uint256 amount) external {}

    function getInvestorStruct(
        address _add
    ) public view returns (investor memory) {
        return investors[investorIndexes[_add]];
    }

    function getContractTRXBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getContractJSTBalance() public view returns (uint256) {
        return jst.balanceOf(address(this));
    }

    function getUserTRXBalance(address _user) public view returns (uint256) {
        return investors[investorIndexes[_user]].balanceTRX;
    }

    function getUserJSTBalance(address _user) public view returns (uint256) {
        return investors[investorIndexes[_user]].balanceJST;
    }

    receive() external payable {}
}
