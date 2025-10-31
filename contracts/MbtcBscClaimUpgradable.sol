// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IMbtcToken {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MbtcBscClaimUpgradable is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
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
        __UUPSUpgradeable_init();

        mbtcToken = IMbtcToken(_mbtcTokenAddress);

        // deployer can upgrade contract
        _grantRole(UPGRADER_ROLE, _msgSender());
        // ADMIN_ROLE
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
    function claimTokens(uint256 _amount) public {
        require(_amount > 0, "Claim amount must be greater than 0");
        require(claimableTokens[msg.sender] >= _amount, "Not enough claimable tokens");

        claimableTokens[msg.sender] -= _amount;


        bool success = mbtcToken.transfer(msg.sender, _amount);
        require(success, "Token transfer failed");

        emit TokensClaimed(msg.sender, _amount);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyRole(UPGRADER_ROLE) {}

    uint256[50] private __gap;
}
