// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Oracle
 * @author RapidLoans
 * @notice A decentralized price oracle for RapidLoans, fetching price of TRX to JST and JST to TRX.
 * @dev Admins can update prices, and users can fetch the latest prices.
 */
contract PriceOracle {
    address public admin;

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
     * @dev Function to set the price of an asset.
     * @param asset The address of the asset (token) to set the price for.
     * @param price The new price in USD (18 decimals).
     */
    function setPrice(address asset, uint256 price) external onlyAdmin {
        require(asset != address(0), "Invalid asset address");
        require(price > 0, "Price must be greater than zero");
        assetPrices[asset] = price;
        emit PriceUpdated(asset, price);
    }

    /**
     * @dev Function to get the latest price of an asset.
     * @param asset The address of the asset (token) to get the price for.
     * @return The price of the asset in USD (18 decimals).
     */
    function getPrice(address asset) external view returns (uint256) {
        uint256 price = assetPrices[asset];
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
