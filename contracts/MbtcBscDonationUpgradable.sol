// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MbtcBscDonationUpgradable
 * Handles Multi-Asset donations (Native BNB & ERC20) with whitelist and minimum amount enforcement.
 */
contract MbtcBscDonationUpgradable is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // [Struct] Token configuration info
    struct TokenConfig {
        bool isAllowed;      // Permission to donate
        uint256 minAmount;   // Minimum donation amount (based on token decimals)
    }

    // [Mapping] Token address => Config info (address(0) represents Native BNB)
    mapping(address => TokenConfig) public allowedTokens;

    // [Events] Log which token (tokenAddress) and how much (amount) was received
    event DonationReceived(address indexed token, address indexed donor, uint256 amount, uint256 timestamp);
    event FundsWithdrawn(address indexed token, address indexed to, uint256 amount);
    event TokenConfigUpdated(address indexed token, bool isAllowed, uint256 minAmount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialAdmin) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _grantRole(UPGRADER_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _initialAdmin);

        // [Default Setup] Native BNB (address(0)) is enabled by default with 0 minimum amount
        allowedTokens[address(0)] = TokenConfig(true, 0);
    }

    // ====================================================
    // 1. Native Coin (BNB/ETH) Donation
    // ====================================================

    /**
     * Default function to receive native tokens directly via transfer.
     */
    receive() external payable {
        _processNativeDonation(msg.sender, msg.value);
    }

    /**
     * Explicit function to donate native tokens.
     */
    function donateNative() external payable {
        _processNativeDonation(msg.sender, msg.value);
    }

    function _processNativeDonation(address _donor, uint256 _amount) internal whenNotPaused {
        TokenConfig memory config = allowedTokens[address(0)];
        require(config.isAllowed, "Native donation not allowed");

        if (config.minAmount > 0) {
            require(_amount >= config.minAmount, "Below minimum donation amount");
        } else {
            require(_amount > 0, "Amount must be > 0");
        }

        // Emit event using address(0) as the token address
        emit DonationReceived(address(0), _donor, _amount, block.timestamp);
    }

    // ====================================================
    // 2. ERC20 Token (WBTC, USDT, etc.) Donation
    // ====================================================

    /**
     * ERC20 token donation.
     * [!] Frontend must call 'approve' on the token contract first.
     */
    function donateERC20(address _token, uint256 _amount) external whenNotPaused nonReentrant {
        TokenConfig memory config = allowedTokens[_token];

        require(config.isAllowed, "Token not allowed");
        require(_amount > 0, "Amount must be > 0");

        if (config.minAmount > 0) {
            require(_amount >= config.minAmount, "Below minimum donation amount");
        }

        // Transfer tokens from user wallet -> contract
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        emit DonationReceived(_token, msg.sender, _amount, block.timestamp);
    }

    // ====================================================
    // 3. Admin & Withdrawal Functions
    // ====================================================

    /**
     * Register/Update token configuration (Whitelist management).
     * @param _token Address of the token (address(0) for Native BNB, otherwise ERC20 address).
   * @param _isAllowed Whether the token is allowed for donation.
   * @param _minAmount Minimum amount adjusted to the token's decimals.
   */
    function setTokenConfig(address _token, bool _isAllowed, uint256 _minAmount) external onlyRole(ADMIN_ROLE) {
        allowedTokens[_token] = TokenConfig(_isAllowed, _minAmount);
        emit TokenConfigUpdated(_token, _isAllowed, _minAmount);
    }

    /**
     * Withdraw accumulated funds (Native or ERC20).
     * @param _token Token address to withdraw (address(0) for Native BNB).
   * @param _to Recipient address.
   */
    function withdraw(address _token, address payable _to) external onlyRole(ADMIN_ROLE) nonReentrant {
        require(_to != address(0), "Invalid address");

        uint256 balance;
        if (_token == address(0)) {
            // Withdraw Native BNB
            balance = address(this).balance;
            require(balance > 0, "No native funds");
            (bool success, ) = _to.call{value: balance}("");
            require(success, "Transfer failed");
        } else {
            // Withdraw ERC20
            balance = IERC20(_token).balanceOf(address(this));
            require(balance > 0, "No token funds");
            IERC20(_token).safeTransfer(_to, balance);
        }

        emit FundsWithdrawn(_token, _to, balance);
    }

    function pauseDonations() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpauseDonations() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyRole(UPGRADER_ROLE) {}

    uint256[50] private __gap;
}
