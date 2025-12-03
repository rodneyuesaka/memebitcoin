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

    uint256 private constant DECIMALS_FACTOR = 10 ** 8;
    uint256 public constant INITIAL_TOTAL_SUPPLY = 210_000_000_000 * DECIMALS_FACTOR;

    // Minimum release interval (Bitcoin homage)
    uint256 public constant RELEASE_INTERVAL = 10 minutes;

    uint256 public constant RELEASE_START_TIME = 1764720000; // Testnet: UTC 2025-12-03 00:00:00
    //    uint256 public constant RELEASE_START_TIME = 1767398400; // Mainnet: UTC 2026-01-03 00:00:00

    uint256 public constant HALVING_PERIOD_DURATION = 24 hours; // Testnet
    //    uint256 public constant HALVING_PERIOD_DURATION = 122 days; // Mainnet , 1/3 of a year (approx. 4 months).

    // Testnet, 1 hour / 10 minutes = 6
    // Mainnet, 122 days / 10 minutes = 17568
    uint256 public HALVING_RELEASES_PER_CYCLE;

    // --- State Variables ---
    uint256 public nextReleaseTime;
    uint256 public currentReleaseAmount;
    address public distributionContract;
    uint256 public periodsReleased; // Total number of 10-minute release periods

    uint256 public releasesUntilHalving; // Number of 10-minute releases remaining until the next halving
    uint256 public currentHalvingCycle; // The current halving cycle number

    // --- Events ---
    event TokensReleased(
        address indexed toContract,
        uint256 amount,
        uint256 period,
        uint256 timestamp
    );
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

        require(HALVING_PERIOD_DURATION % RELEASE_INTERVAL == 0, "Intervals must be divisible");
        HALVING_RELEASES_PER_CYCLE = HALVING_PERIOD_DURATION / RELEASE_INTERVAL;
        currentReleaseAmount = (INITIAL_TOTAL_SUPPLY / 2) / HALVING_RELEASES_PER_CYCLE;

        // Initialize halving trackers
        releasesUntilHalving = HALVING_RELEASES_PER_CYCLE;
        currentHalvingCycle = 0;

        _mint(address(this), INITIAL_TOTAL_SUPPLY);
        nextReleaseTime = RELEASE_START_TIME;
        periodsReleased = 0;
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    /**
     * Releases tokens to the 'Distribution Contract' when the release period is reached (every 10 minutes) and applies halving logic when the cycle is complete.
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
        nextReleaseTime += RELEASE_INTERVAL;
        releasesUntilHalving--;

        // Apply halving logic when the cycle is complete
        if (releasesUntilHalving == 0) {
            currentHalvingCycle++;
            releasesUntilHalving = HALVING_RELEASES_PER_CYCLE;
            currentReleaseAmount = currentReleaseAmount / 2;
        }

        // Send token to the Distribution Contract
        _transfer(address(this), distributionContract, amountToRelease);

        emit TokensReleased(distributionContract, amountToRelease, periodsReleased, block.timestamp);
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

