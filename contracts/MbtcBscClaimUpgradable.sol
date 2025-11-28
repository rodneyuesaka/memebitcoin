// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

interface IMbtcToken {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MbtcBscClaimUpgradable is Initializable, AccessControlUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    IMbtcToken public mbtcToken;

    mapping(address => uint256) public claimableTokens;

    event TokensAssigned(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _mbtcTokenAddress, address _initialAdmin) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        mbtcToken = IMbtcToken(_mbtcTokenAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
        _grantRole(UPGRADER_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _initialAdmin);
    }

    /**
     * ADMIN_ROLE only. Assigns claimable tokens to a user.
     */
    function assignTokens(address _user, uint256 _amount) public onlyRole(ADMIN_ROLE) {
        claimableTokens[_user] = _amount;
        emit TokensAssigned(_user, _amount);
    }

    /**
     * User claims their assigned tokens. Tokens are sent from this Claim contract's balance.
     */
    function claimTokens(uint256 _amount) public whenNotPaused {
        require(_amount > 0, "Claim amount must be greater than 0");
        require(claimableTokens[msg.sender] >= _amount, "Not enough claimable tokens");

        claimableTokens[msg.sender] -= _amount;


        bool success = mbtcToken.transfer(msg.sender, _amount);
        require(success, "Token transfer failed");

        emit TokensClaimed(msg.sender, _amount);
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

    function _authorizeUpgrade(address newImplementation) internal view override onlyRole(UPGRADER_ROLE) {}

    uint256[50] private __gap;
}
