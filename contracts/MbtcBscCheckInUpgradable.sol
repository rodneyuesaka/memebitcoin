// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MbtcBscCheckInUpgradable is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    mapping(address => uint256) public lastCheckIn;
    event UserCheckedIn(address indexed user, uint256 timestamp);

    uint256 public cooldownPeriod;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 _initialCooldown, address _initialOwner) public initializer {
        __Ownable_init(_initialOwner);
        cooldownPeriod = _initialCooldown;
    }

    function checkIn() public {
        require(
            block.timestamp >= lastCheckIn[msg.sender] + cooldownPeriod,
            "CheckIn: Cooldown period has not passed."
        );
        lastCheckIn[msg.sender] = block.timestamp;
        emit UserCheckedIn(msg.sender, block.timestamp);
    }

    function setCooldownPeriod(uint256 _newCooldown) public onlyOwner {
        cooldownPeriod = _newCooldown;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}