// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title UserVault
 * @author RapidLoans Team
 * @notice This contract allows users to deposit, withdraw, and manage their assets for use in flash loans and other financial services.
 * @dev The UserVault contract facilitates secure management of user assets and provides functions for deposit and withdrawal.
 */

contract UserVault {
    address public admin;
r
    struct Vault {
        uint256 trxBalance;  // Balance of TRX in the vault
        uint256 jstBalance;  // Balance of JST (an ERC20 token) in the vault
    }

    mapping(address => Vault) private userVaults;

    event Deposited(address indexed user, string token, uint256 amount);
    event Withdrawn(address indexed user, string token, uint256 amount);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    constructor() {
        admin = msg.sender; // Set the deployer as the admin
    }

    /**
     * @dev Allows users to deposit TRX into their vault.
     * Emits a `Deposited` event.
     */
    function depositTRX() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        userVaults[msg.sender].trxBalance += msg.value;

        emit Deposited(msg.sender, "TRX", msg.value);
    }

    /**
     * @dev Allows users to deposit JST tokens into their vault.
     * @param amount Amount of JST tokens to deposit.
     * Emits a `Deposited` event.
     */
    function depositJST(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        require(IERC20(jstTokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer of JST failed");

        userVaults[msg.sender].jstBalance += amount;

        emit Deposited(msg.sender, "JST", amount);
    }

    /**
     * @dev Allows users to withdraw TRX from their vault.
     * @param amount The amount of TRX to withdraw.
     * Emits a `Withdrawn` event.
     */
    function withdrawTRX(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(userVaults[msg.sender].trxBalance >= amount, "Insufficient TRX balance");

        userVaults[msg.sender].trxBalance -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, "TRX", amount);
    }

    /**
     * @dev Allows users to withdraw JST tokens from their vault.
     * @param amount The amount of JST to withdraw.
     * Emits a `Withdrawn` event.
     */
    function withdrawJST(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(userVaults[msg.sender].jstBalance >= amount, "Insufficient JST balance");

        userVaults[msg.sender].jstBalance -= amount;

        require(IERC20(jstTokenAddress).transfer(msg.sender, amount), "Transfer of JST failed");

        emit Withdrawn(msg.sender, "JST", amount);
    }

    /**
     * @dev Allows the admin to change the admin address.
     * @param newAdmin The address of the new admin.
     * Emits an `AdminChanged` event.
     */
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        emit AdminChanged(admin, newAdmin); // Emit event before changing admin
        admin = newAdmin; // Update the admin address
    }

    /**
     * @dev Get the TRX balance of the caller's vault.
     * @return The TRX balance of the user.
     */
    function getTRXBalance() external view returns (uint256) {
        return userVaults[msg.sender].trxBalance;
    }

    /**
     * @dev Get the JST balance of the caller's vault.
     * @return The JST balance of the user.
     */
    function getJSTBalance() external view returns (uint256) {
        return userVaults[msg.sender].jstBalance;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
