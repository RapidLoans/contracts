// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @title Oracle
 * @author RapidLoans
 * @notice A decentralized price oracle for RapidLoans, fetching price of TRX to JST and JST to TRX.
 * @dev Admins can update prices, and users can fetch the latest prices.
 */
contract PriceOracle {
    address public admin;
    address public TRX = address(1);
    address public JST = address(2);

    mapping(address => uint256) public assetPrices;

    event PriceUpdated(address indexed asset, uint256 newPrice);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @dev Function to set the price of an TRX to JST.
     * @param price The new price in JST (18 decimals).
     */
    function setTRXToJST(uint256 price) external onlyAdmin {
        require(price > 0, "Price must be greater than zero");
        assetPrices[TRX] = price;
        emit PriceUpdated(TRX, price);
    }

    /**
     * @dev Function to set the price of an JST to TRX.
     * @param price The new price in TRX (18 decimals).
     */
    function setJSTToTRX(uint256 price) external onlyAdmin {
        require(price > 0, "Price must be greater than zero");
        assetPrices[JST] = price;
        emit PriceUpdated(JST, price);
    }

    /**
     * @dev Function to get the latest price of TRX in JST.
     * @param amount of TRX to convert to JST.
     * @return The price of corrosponding TRX asset in JST (18 decimals).
     */
    function getTRXToJST(uint256 amount) external view returns (uint256) {
        uint256 price = assetPrices[TRX] * amount;
        require(price > 0, "Price not available for the given asset");
        return price;
    }

    /**
     * @notice Function to get the latest price of JST in TRX.
     * @param amount of JST to convert to TRX.
     * @return The price of corrosponding JST asset in TRX (18 decimals).
     */
    function getJSTToTRX(uint256 amount) external view returns (uint256) {
        uint256 price = assetPrices[JST] * amount;
        require(price > 0, "Price not available for the given asset");
        return price;
    }

    /**
     * @dev Function to change the admin of the contract.
     * @param newAdmin The address of the new admin.
     */
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid new admin address");
        admin = newAdmin;
    }
}
