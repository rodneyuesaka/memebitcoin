// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * MbtcBscTokenUpgradable
 *
 * Upgradable ERC20 token with periodic, halving release schedule.
 * [!] This contract sends released tokens to a distribution/claim contract.
 */
contract MbtcBscTokenUpgradable is
Initializable,
ERC20Upgradeable,
OwnableUpgradeable,
ReentrancyGuardUpgradeable,
AccessControlUpgradeable,
UUPSUpgradeable
{

    // --- Constants ---
    string public constant TOKEN_NAME = "Meme Bitcoin";
    string public constant TOKEN_SYMBOL = "MBTC";

    uint256 private constant DECIMALS_FACTOR = 10 ** 18;
    uint256 public constant INITIAL_TOTAL_SUPPLY = 210_000_000_000 * DECIMALS_FACTOR;

    uint256 public constant PERIOD_DURATION = 1 hours; // Testnet
//    uint256 public constant PERIOD_DURATION = 122 days; // Mainnet , 1/3 of a year (approx. 4 months).

    uint256 public constant RELEASE_START_TIME = 1761868800; // Testnet: UTC 2025-10-31 00:00:00
//    uint256 public constant RELEASE_START_TIME = 1767225600; // Mainnet: UTC 2026-01-03 00:00:00

    // --- State Variables ---
    uint256 public nextReleaseTime;
    uint256 public currentReleaseAmount;
    address public distributionContract;
    uint256 public periodsReleased;

    // --- Events ---
    event TokensReleased(address indexed toContract, uint256 amount, uint256 period);
    event DistributionContractChanged(address indexed newContract);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        address _distributionContract
    ) public initializer {

        __ERC20_init(TOKEN_NAME, TOKEN_SYMBOL);
        __Ownable_init(_initialOwner);
        __ReentrancyGuard_init();

        distributionContract = _distributionContract;

        // Automatically calculates the first release amount as half of the total supply.
        currentReleaseAmount = INITIAL_TOTAL_SUPPLY / 2;

        _mint(address(this), INITIAL_TOTAL_SUPPLY);

        nextReleaseTime = RELEASE_START_TIME;
        periodsReleased = 0;
    }

    /**
     * Releases tokens to the 'Distribution Contract' when the release period is reached (approx. 4 months).
     */
    function releaseTokens() external onlyOwner nonReentrant {
        require(block.timestamp >= nextReleaseTime, "Release period not yet reached");
        require(distributionContract != address(0), "Distribution contract not set");

        uint256 amountToRelease = currentReleaseAmount;
        uint256 contractBalance = balanceOf(address(this));

        if (amountToRelease > contractBalance) {
            amountToRelease = contractBalance;
        }

        require(amountToRelease > 0, "No tokens left to release");

        // Update state variables for the next release
        periodsReleased++;
        nextReleaseTime += PERIOD_DURATION;
        currentReleaseAmount = currentReleaseAmount / 2;

        // Send token to the Distribution Contract
        _transfer(address(this), distributionContract, amountToRelease);

        emit TokensReleased(distributionContract, amountToRelease, periodsReleased);
    }

    /**
     * Changes the address of the 'Distribution Contract' that will receive the release.
     */
    function setDistributionContract(address _newContract) external onlyOwner {
        require(_newContract != address(0), "New contract cannot be zero address");
        distributionContract = _newContract;
        emit DistributionContractChanged(_newContract);
    }

    /**
     * Returns the amount of tokens locked (not yet released) in the current contract.
       */
    function getLockedTokenBalance() external view returns (uint256) {
        return balanceOf(address(this));
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {}

    uint256[50] private __gap;
}

