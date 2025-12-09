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

| Version    | Contract Type      | Address                                                                                                                          | Status     |
|:-----------|:-------------------|:---------------------------------------------------------------------------------------------------------------------------------|:-----------|
| **v0.4.0** | **Token (Latest)** | **[0xAC3E72795FDC9Bb2e5714b7fd17E2cAf909611D2](https://testnet.bscscan.com/token/0xAC3E72795FDC9Bb2e5714b7fd17E2cAf909611D2)**   | **Active** |
| **v0.4.1** | **Claim (Latest)** | **[0xb60EFb7485072E8FD5eDCB79Ef3712416710f5B2](https://testnet.bscscan.com/address/0xb60EFb7485072E8FD5eDCB79Ef3712416710f5B2)** | **Active** |
| **v0.1.0** | **Checkin**        | **[0xfC84c4C01881628b855d214aAfB99215F67cfC6f](https://testnet.bscscan.com/address/0xfC84c4C01881628b855d214aAfB99215F67cfC6f)** | **Active** |
| **v0.4.0** | **Donation** | **[0xb795cE8B16114A12F2557155b365d456a436EbC0](https://testnet.bscscan.com/address/0xb795cE8B16114A12F2557155b365d456a436EbC0)** | **Active** |

---

# ⏳ Halving & Release Logic (v0.4.0 Update)

The entire supply is minted to the Token contract address upon deployment and is released periodically to the designated Distribution Contract.

### **Current Testnet Configuration (Fast Cycle)**

| Parameter | Value (v0.4.0) | Description |
| :--- | :--- | :--- |
| **Release Start Time** | UTC 2025-12-03 00:00:00 | Unix Timestamp: `1764720000` |
| **Release Interval** | **10 minutes** | Tokens are released every 10 mins. |
| **Halving Period** | **24 hours (1 Day)** | Halving occurs every 144 releases |

- **Mechanism:** The `releaseTokens()` function transfers the scheduled amount from the Token Contract to the `Distribution Contract` (Claim Contract).
- **Halving:** The release amount is halved every **24 hours** (Testnet setting) to simulate the deflationary model quickly.

---

# 🪙 Claim & Distribution Logic (v0.4.1 Update)

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

# 💸 Donation Infrastructure (v0.4.0 New)

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

# 🪙 Claim & Distribution Logic (v0.4.0 Update)

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
