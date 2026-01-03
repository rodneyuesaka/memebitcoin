# 🚀 Meme Bitcoin (MBTC)

Meme Bitcoin (MBTC) is an upgradable ERC-20 token deployed on the **Binance Smart Chain (BSC) Mainnet**.
It features a programmatic, halving-based release schedule enforced entirely by on-chain contract logic, inspired by Bitcoin’s monetary policy.

---

## 📌 Contract Details

| Detail               | Value                                                                 |
|----------------------|-----------------------------------------------------------------------|
| **Network**          | Binance Smart Chain (BSC)                                              |
| **Website**          | https://memebitcoin.org                                                |
| **Upgrade Standard** | UUPS (ERC1967)                                                         |
| **Total Supply**     | 210,000,000,000 MBTC (Bitcoin Homage)                                  |
| **Decimals**         | 8 (Bitcoin Homage)                                                     |
| **Release Start**    | 2026-01-03 18:15:05 UTC (Epoch of the MBTC ecosystem)                  |
| **Release Interval** | 10 minutes (Mimics Bitcoin’s average block time)                       |
| **Halving Period**   | 122 days (≈ 1/3 year, deflationary schedule)                           |

---

## 📍 Smart Contract Address (BSC)

| Version    | Contract Type      | Address                                                                                                                                                                                                                                                                                                                                                                                                                        | Status     |
|:-----------|:-------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------|
| **v1.0.0** | **Token (Latest)** | **[0x3b93314430A7db7d614eB3A6c226dEa01973d0Ef](https://bscscan.com/token/0x3b93314430A7db7d614eB3A6c226dEa01973d0Ef)**                                                                                                                                                                                                                                                                                                         | **Active** |
| **v1.0.0** | **Claim (Latest)** | **[0xeE53735Ca6660aB261A07abfbCA7CA66e56a70A4](https://bscscan.com/address/0xeE53735Ca6660aB261A07abfbCA7CA66e56a70A4)**                                                                                                                                                                                                                                                                                                       | **Active** |
| **v1.0.0** | **Checkin**        | **[0xB01F829C8FbDE797378a23B5eb48C3dD44926fC4](https://bscscan.com/address/0xB01F829C8FbDE797378a23B5eb48C3dD44926fC4)**                                                                                                                                                                                                                                                                                                       | **Active** |
| **v1.0.0** | **Donation** | **[0xC68c3A5a797d51DB7d4503928238977BE8A0d05f](https://bscscan.com/address/0xC68c3A5a797d51DB7d4503928238977BE8A0d05f)**                                                                                                                                                                                                                                                                                                                                                 | **Active** |

---

## ⏳ Decentralized Token Emission (v1.0.0 Update)

The most significant update in v1.0.0 is the decentralization of the token release trigger. MBTC moves away from centralized administrative control towards a permissionless "heartbeat" mechanism.

### **Permissionless Release Execution**

- Mechanism: The releaseTokens() function no longer requires the onlyOwner modifier.
- Decentralization: Any user or bot can call releaseTokens() once the 10-minute interval has passed. This ensures that the token emission continues even without the direct intervention of the project team.
- Safety Guarantee: Although the trigger is public, the destination is immutable. Released tokens are strictly transferred to the pre-set Distribution Contract (Claim Contract). No external caller can divert these funds.

---

## 🪙 Claim & Distribution Logic

The `MbtcBscClaimUpgradable` contract serves as the secure vault for released tokens and manages reward distribution.

### **v1.0.0 Security & Operations Patch**
1. **Reentrancy Protection:** All claim functions are protected by `nonReentrant` modifiers to prevent drain attacks.
2. **Flexible Assignment:**
- `assignTokens`: Overwrites the user balance (Direct adjustment).
- `increaseTokens`: Adds to the existing balance (Accumulated rewards).
3. **Operational Flow:**
- **Admin:** Sets eligibility via `ADMIN_ROLE` based on ecosystem activity.
- **User:** Calls `claimTokens(amount)` to withdraw MBTC to their private wallet.

---

## 🛠️ Infrastructure Utilities

### **Check-in System (v1.0.0)**
An on-chain activity logger. Users execute `checkIn()` to record their presence. Off-chain services (Yroun Hub) verify these streaks to assign rewards via the Claim contract.

### **Donation Gateway (v1.0.0)**
Secure infrastructure for community contributions.

- Supports **Native BNB** and whitelisted **ERC20 tokens** on BNB Smart Chain.
- Currently supported ERC20s:
    - **BTCB (Binance-Peg BTC)**
      [`0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c`](https://bscscan.com/token/0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c)
- Minimum donation thresholds prevent dust spam.
- All funds are recoverable and manageable via multi-sig governance.

---

## 📜 Version History & Changelog

<details>
<summary>View Past Version Details (v0.3.0 - v0.4.1)</summary>

## ⏳ Halving & Release Logic (v0.4.0 Update)

The entire supply is minted to the Token contract address upon deployment and is released periodically to the designated Distribution Contract.

### **Current Testnet Configuration (Fast Cycle)**

| Parameter | Value (v0.4.0)          | Description |
| :--- |:------------------------| :--- |
| **Release Start Time** | UTC 2026-01-03 18:15:05 | Unix Timestamp: `1767464105` |
| **Release Interval** | **10 minutes**          | Tokens are released every 10 mins. |
| **Halving Period** | **24 hours (1 Day)**    | Halving occurs every 144 releases |

- **Mechanism:** The `releaseTokens()` function transfers the scheduled amount from the Token Contract to the `Distribution Contract` (Claim Contract).
- **Halving:** The release amount is halved every **24 hours** (Testnet setting) to simulate the deflationary model quickly.

---

## 🪙 Claim & Distribution Logic (v0.4.1 Update)

The `MbtcBscClaimUpgradable` contract is responsible for receiving the released tokens and managing the final distribution to end-users.

### **v0.4.1 Patch Notes (Operational Optimization)**
1.  **Batch Assignment:** Introduced `batchAssignTokens` to assign rewards to multiple users in a single transaction, significantly reducing gas costs.
2.  **Blocklist Governance:** Replaced the legacy blacklist system with a standard `Blocklist` mechanism (`isBlocked`, `setBlockStatus`) to manage access and prevent abuse.

### **Operational Flow**

| Step | Detail | Roles |
| :--- | :--- | :--- |
| **1. Batch Assign** | An external service calls `batchAssignTokens([users], [amounts])`. User balances are synchronized with the backend. | `ADMIN_ROLE` |
| **2. Claim Tokens** | The user calls `claimTokens(amount)`. The contract checks if the user is **blocked**, verifies the balance, and transfers MBTC. | User (whenNotPaused) |
| **3. Governance** | Admin can use `setBlockStatus(user, bool)` to restrict specific addresses from claiming tokens in case of policy violations. | `ADMIN_ROLE` |

---

## 💸 Donation Infrastructure (v0.4.0 New)

The `MbtcBscDonationUpgradable` contract provides a secure infrastructure for receiving multiple asset types and tracking contributions via on-chain events.

### **Key Features**
1.  **Multi-Asset Support:** Accepts both **Native BNB** and whitelisted **ERC20 Tokens** (e.g., WBTC, USDT).
2.  **Spam Protection:** Administrators can set a **Minimum Donation Amount** per token to prevent dust attacks and log spam.
3.  **Asset Rescue:** The generic `withdraw` function allows administrators to recover any token sent to the contract (including non-whitelisted ones), preventing accidental asset loss.

### **How it works**

| Action | Function Call | Description |
| :--- | :--- | :--- |
| **Native Donation** | `receive()` or `donateNative()` | Users send BNB directly. The contract emits `DonationReceived(address(0), ...)` for backend tracking. |
| **ERC20 Donation** | `donateERC20(token, amount)` | Users approve and donate ERC20 tokens. The contract verifies the whitelist and emits `DonationReceived(token, ...)`. |
| **Withdrawal** | `withdraw(token, recipient)` | Admin withdraws accumulated funds. Can be used for revenue collection or rescuing lost assets. |

---

## 🪙 Claim & Distribution Logic (v0.4.0 Update)

The `MbtcBscClaimUpgradable` contract is responsible for receiving the released tokens and managing the final distribution to end-users.

### **v0.4.0 Patch Notes (Major Safety Update)**
1.  **Safety First:** Added `recoverERC20` to rescue tokens accidentally sent to the contract address.
2.  **Assignment Control:** Maintained `assignTokens` as an overwrite (`=`) operation, allowing Admins to set exact balances or revoke eligibility.
3.  **Maintainability:** Added `setTokenAddress` to update the token contract linkage without redeploying.
4.  **Optimization:** Migrated to standard `IERC20` interface for better compatibility and gas efficiency.

### **Operational Flow**

| Step | Detail | Roles |
| :--- | :--- | :--- |
| **1. Assign Eligibility** | An external service calls `assignTokens(user, amount)`. The user's `claimableTokens` balance is **set** to the specified amount (overwrite). | `ADMIN_ROLE` |
| **2. Claim Tokens** | The user calls `claimTokens(amount)`. The contract verifies the balance and transfers MBTC from its own balance to the user's wallet. | User (whenNotPaused) |
| **3. Emergency Recovery**| Admin can call `recoverERC20` to return any ERC20 tokens sent to the contract by mistake. | `ADMIN_ROLE` |

---

## ⏳ Halving & Release Logic (v0.3.0 Update)

The entire supply is minted to the Token contract address upon deployment and is released periodically to the designated Distribution Contract.

| Parameter | Value (Testnet) | Mainnet Target |
| :--- | :--- | :--- |
| **Release Start Time** | UTC 2025-11-24 00:00:00 (`1763942400`) | UTC 2026-01-03 00:00:00 (`1767225600`) |
| **Release Interval** | **10 minutes** | 10 minutes |
| **Halving Period Duration** | **4 hours** | 122 days |
| **Releases Per Cycle** | 24 (4 hours / 10 min) | 17568 (122 days / 10 min) |

- **Mechanism:** The `releaseTokens()` function transfers the calculated scheduled amount from the locked contract balance to the `distributionContract` address every 10 minutes, provided the time has elapsed.
- **Halving:** The release amount is halved once the current Halving Cycle is complete (every 4 hours on Testnet).

## 🪙 Claim & Distribution Logic (v0.3.0 Update)

The `MbtcBscClaimUpgradable` contract is responsible for receiving the released tokens and managing the final distribution to end-users.

| Step | Detail | Roles |
| :--- | :--- | :--- |
| **1. Assign Eligibility** | An external service (e.g., Check-in handler) calls `assignTokens(user, amount)` to credit the user's `claimableTokens` balance. | `ADMIN_ROLE` |
| **2. Claim Tokens** | The user calls `claimTokens(amount)`. The contract verifies the balance and transfers MBTC from its own balance to the user's wallet. | User (whenNotPaused) |
| **Security** | The contract implements **OpenZeppelin Access Control** (`ADMIN_ROLE`, `UPGRADER_ROLE`) and a **Pausable** feature (`pauseClaims()`, `unpauseClaims()`). | `ADMIN_ROLE` (for pausing/unpausing) |

## 📝 Check-in Logic

The Check-in Smart Contract is a separate utility contract designed to record basic user activity on-chain.

- **Purpose:** Allows users to execute a simple `checkIn()` transaction (daily/cooldown).
- **Functionality:** Records the user's last activity timestamp (`lastCheckIn`) and emits a `UserCheckedIn` event.
- **Reward Connection**: An off-chain service monitors the `UserCheckedIn` event, calculates rewards based on engagement streaks, and then uses its privileged `ADMIN_ROLE` to call `assignTokens()` on the **Claim Contract**.
</details>
