// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MbtcBscClaimUpgradable is Initializable, AccessControlUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    IERC20 public mbtcToken;

    mapping(address => uint256) public claimableTokens;
    mapping(address => bool) public isBlocked;

    uint256 public totalClaimed;

    event TokensAssigned(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);
    event TokenAddressUpdated(address oldAddress, address newAddress);
    event BlockStatusUpdated(address indexed user, bool status);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _mbtcTokenAddress, address _initialAdmin) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        mbtcToken = IERC20(_mbtcTokenAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _grantRole(UPGRADER_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _initialAdmin);
    }

    /**
     * ADMIN_ROLE only. Assigns claimable tokens to a user.
     */
    function assignTokens(address user, uint256 amount) public onlyRole(ADMIN_ROLE) {
        _assignTokens(user, amount);
    }

    /**
     * Batch assigns tokens to multiple users. Saves gas.
       */
    function batchAssignTokens(address[] memory _users, uint256[] memory _amounts) public onlyRole(ADMIN_ROLE) {
        require(_users.length == _amounts.length, "Arrays length mismatch");
        for (uint256 i = 0; i < _users.length; i++) {
            _assignTokens(_users[i], _amounts[i]);
        }
    }

    function _assignTokens(address user, uint256 amount) internal {
        claimableTokens[user] = amount;
        emit TokensAssigned(user, amount);
    }

    /**
     * User claims their assigned tokens. Tokens are sent from this Claim contract's balance.
     */
    function claimTokens(uint256 _amount) public whenNotPaused {
        require(!isBlocked[msg.sender], "Address is blocked");
        require(_amount > 0, "Claim amount must be greater than 0");
        require(claimableTokens[msg.sender] >= _amount, "Not enough claimable tokens");

        claimableTokens[msg.sender] -= _amount;


        bool success = mbtcToken.transfer(msg.sender, _amount);
        require(success, "Token transfer failed");

        emit TokensClaimed(msg.sender, _amount);
    }

    function setBlockStatus(address _user, bool _status) public onlyRole(ADMIN_ROLE) {
        isBlocked[_user] = _status;
        emit BlockStatusUpdated(_user, _status);
    }

    /**
     * Pausing claims during token allocation is a critical security measure
     * to prevent unforeseen accidents or malicious attacks.
     */
    function pauseClaims() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpauseClaims() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * Recovers ERC20 tokens sent to this contract by mistake.
     * This function allows the admin to return tokens accidentally transferred
     * directly to the contract address by users, or to migrate funds during upgrades.
     */
    function recoverERC20(address _token, uint256 _amount) public onlyRole(ADMIN_ROLE) {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    /**
       * Updates the MBTC token contract address.
       */
    function setTokenAddress(address _newTokenAddress) public onlyRole(ADMIN_ROLE) {
        require(_newTokenAddress != address(0), "Invalid address");

        address oldAddress = address(mbtcToken);

        mbtcToken = IERC20(_newTokenAddress);

        emit TokenAddressUpdated(oldAddress, _newTokenAddress);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyRole(UPGRADER_ROLE) {}

    uint256[48] private __gap;
}
