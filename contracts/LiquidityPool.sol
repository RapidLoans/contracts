// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title LendingPool.
 * @author RapidLoans.
 * @notice A lending pool for Rapidloans to issue flash loans from.
 * @dev Token pair used currently is TRX/JST.
 */

contract LiquidityPool {
    struct investor {
        address investor;
        uint256 balanceTRX;
        uint256 balanceJST;
    }

    investor[] internal investors;

    mapping(address => uint256) internal investorIndexes;

    error LendingPool__invalidAmount();

    constructor() {
        investor memory initialInvestor = investor({
            investor: address(0),
            balanceTRX: 0,
            balanceJST: 0
        });
        investors.push(initialInvestor);
        investorIndexes[address(0)] = 0;
    }

    function addTRX() external payable {
        require(msg.sender != address(0), "Invalid sender address");
        // require(msg.value > 0, LendingPool__invalidAmount());
        if (investorIndexes[msg.sender] == 0) {
            investor memory temp = investor({
                investor: msg.sender,
                balanceTRX: msg.value,
                balanceJST: 0
            });
            investors.push(temp);
            investorIndexes[msg.sender] = investors.length - 1;
        } else {
            investors[investorIndexes[msg.sender]].balanceTRX += msg.value;
        }
    }

    function addJST(uint256 amount) external payable {}

    function flashLoanTRX(uint256 amount) external payable {}

    function flashLoanJST(uint256 amount) external payable {}

    function getInvestorStruct() public view returns (investor memory) {
        return investors[investorIndexes[msg.sender]];
    }
}
