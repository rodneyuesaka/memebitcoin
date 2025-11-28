# 🚀 Meme Bitcoin (MBTC)

This is an Upgradable ERC-20 token contract deployed on the **BSC Testnet**. It features a programmatic, halving release schedule managed by the contract logic.

# 📌 Contract Details

| Detail | Value |
| :--- | :--- |
| **Network** | BSC Testnet |
| **Website** | **[https://memebitcoin.org](https://memebitcoin.org)** |
| **Upgrade Standard** | UUPS (Upgradable) |
| **Total Supply** | 210,000,000,000 MBTC |
| **Decimals** | 8 |

# Smart Contract Address (BSC Testnet)

| Version | Contract Type | Address | Status |
| :--- | :--- | :--- | :--- |
| **v0.3.0** | **Token (Current)** | **[0xe13d91a5dBd13dFe7AF52ffFA40f314c83AB8436](https://testnet.bscscan.com/token/0xe13d91a5dBd13dFe7AF52ffFA40f314c83AB8436)** | Active |
| **v0.3.0** | **Claim (Current)** | **[0x4b35BFa89F14F38DC1d545cC059Be005DbeB5364](https://testnet.bscscan.com/address/0x4b35BFa89F14F38DC1d545cC059Be005DbeB5364)** | Active |
| v0.2.1 | Token | [0x480e79b6FE44bd8da3B8C979ce6ce4F5c99593f1](https://testnet.bscscan.com/token/0x480e79b6FE44bd8da3B8C979ce6ce4F5c99593f1) | Deprecated |
| v0.2.1 | Claim | [0x770585251f6070038Bfaa9b904207e0E6f87C804](https://testnet.bscscan.com/address/0x770585251f6070038Bfaa9b904207e0E6f87C804) | Deprecated |
| v0.1.0 | Checkin | [0xfC84c4C01881628b855d214aAfB99215F67cfC6f](https://testnet.bscscan.com/address/0xfC84c4C01881628b855d214aAfB99215F67cfC6f) | Active |

---

# ⚙️ Protocol Evolution History

### v0.3.0: Security, Delegation, and Schedule Finalization
This version introduces critical updates to governance and tokenomics:
* **Access Control:** The Claim Contract implements robust OpenZeppelin Access Control, establishing an `ADMIN_ROLE` to delegate operational management (like pausing claims or assigning tokens) away from the main contract Owner.
* **Tokenomics:** The Testnet release schedule constants were updated to increase `HALVING_PERIOD_DURATION` to **4 hours** and adjust the `RELEASE_START_TIME`.

### v0.2.1: Claim Contract Security Enhancement
* **Pausable Feature:** Introduced the `Pausable` feature to the Claim Contract (`MbtcBscClaimUpgradable`).
* **Security Measure:** Allows the **Contract Owner** (via the inherited Default Admin Role) to temporarily pause and unpause the `claimTokens()` function to protect contract assets during unforeseen circumstances or critical allocations.
    * *Note: This pausing capability was later secured by the dedicated `ADMIN_ROLE` in v0.3.0.* 👈 **(옵션: 맥락을 위한 추가 주석)**

### v0.2.0: Automated Distribution and Decimal Standardization
This version focused on standardization and programmatic supply:
* **Automated Release:** Tokens are now automatically released from the Token Contract to the Claim Contract at a regular interval of **every 10 minutes** (`RELEASE_INTERVAL`).
* **Decimal Standardization:** Token decimals were officially set to **8** to align with global standards.

---

# ⏳ Halving & Release Logic (v0.3.0 Update)

The entire supply is minted to the Token contract address upon deployment and is released periodically to the designated Distribution Contract.

| Parameter | Value (Testnet) | Mainnet Target |
| :--- | :--- | :--- |
| **Release Start Time** | UTC 2025-11-24 00:00:00 (`1763942400`) | UTC 2026-01-03 00:00:00 (`1767225600`) |
| **Release Interval** | **10 minutes** | 10 minutes |
| **Halving Period Duration** | **4 hours** | 122 days |
| **Releases Per Cycle** | 24 (4 hours / 10 min) | 17568 (122 days / 10 min) |

- **Mechanism:** The `releaseTokens()` function transfers the calculated scheduled amount from the locked contract balance to the `distributionContract` address every 10 minutes, provided the time has elapsed.
- **Halving:** The release amount is halved once the current Halving Cycle is complete (every 4 hours on Testnet).

# 🪙 Claim & Distribution Logic (v0.3.0 Update)

The `MbtcBscClaimUpgradable` contract is responsible for receiving the released tokens and managing the final distribution to end-users.

| Step | Detail | Roles |
| :--- | :--- | :--- |
| **1. Assign Eligibility** | An external service (e.g., Check-in handler) calls `assignTokens(user, amount)` to credit the user's `claimableTokens` balance. | `ADMIN_ROLE` |
| **2. Claim Tokens** | The user calls `claimTokens(amount)`. The contract verifies the balance and transfers MBTC from its own balance to the user's wallet. | User (whenNotPaused) |
| **Security** | The contract implements **OpenZeppelin Access Control** (`ADMIN_ROLE`, `UPGRADER_ROLE`) and a **Pausable** feature (`pauseClaims()`, `unpauseClaims()`). | `ADMIN_ROLE` (for pausing/unpausing) |

# 📝 Check-in Logic

The Check-in Smart Contract is a separate utility contract designed to record basic user activity on-chain.

- **Purpose:** Allows users to execute a simple `checkIn()` transaction (daily/cooldown).
- **Functionality:** Records the user's last activity timestamp (`lastCheckIn`) and emits a `UserCheckedIn` event.
- **Reward Connection**: An off-chain service monitors the `UserCheckedIn` event, calculates rewards based on engagement streaks, and then uses its privileged `ADMIN_ROLE` to call `assignTokens()` on the **Claim Contract**.