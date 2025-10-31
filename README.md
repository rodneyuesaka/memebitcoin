# 🚀 Meme Bitcoin (MBTC)

This is an Upgradable ERC-20 token contract deployed on the BSC Testnet. It features a halving release schedule managed by the contract owner.

# 📌 Deployment Summary

| Detail                     | Value                                                                                                                                        |
|:---------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------|
| **Network**                | BSC Testnet                                                                                                                                  |
| **Website** | **[https://memebitcoin.org](https://memebitcoin.org)** |
| **Token Smart Contract**   | [0x1572CDd83987FCFbdf3e53b4b1d00F37E95C198B (View on BscScan)](https://testnet.bscscan.com/token/0x1572CDd83987FCFbdf3e53b4b1d00F37E95C198B) |
| **Claim Smart Contract**   | [0x52db3E6482642Dc55fcFe547cE8d466E69b590cD (View on BscScan)](https://testnet.bscscan.com/address/0x52db3E6482642Dc55fcFe547cE8d466E69b590cD) |
| **Checkin Smart Contract** | [0x61244616Ad0dE6d2610865223d5Af17471994Ce3 (View on BscScan)](https://testnet.bscscan.com/address/0x61244616Ad0dE6d2610865223d5Af17471994Ce3) |
| **Upgrade Standard**           | UUPS                                                                                                                                         |
| **Total Supply**               | 210,000,000,000 MBTC                                                                                                                         |


# ⏳ Halving & Release Logic

The entire supply is minted to the contract address upon deployment and is released periodically via the releaseTokens() function.

- Release Cycle: The token release amount is halved every 122 days (approx. 4 months).
- Start Time: The schedule begins on 2025-10-31 00:00:00 UTC.
- Functionality: The releaseTokens() function transfers the scheduled amount from the locked contract balance to the designated distributionContract address.

# 🪙 Claim & Distribution Logic

The Claim Smart Contract receives the tokens released from the main Token Contract. This contract is responsible for managing the final distribution to end-users.

This process involves two steps:

1. Assignment (Eligibility): A user's wallet address is designated as eligible to claim a specific amount of tokens. This eligibility is recorded in the contract's on-chain ledger (claimableTokens mapping). This step credits the user's account with a claimable balance but does not transfer any tokens yet.

2. Claim (User Action): The user initiates the claimTokens(uint256 amount) function. The contract verifies the user's claimable balance (from Step 1) and, if sufficient, transfers the requested amount of MBTC to their wallet.

# 📝 Check-in Logic
The Check-in Smart Contract is a separate utility contract designed to record user activity.

- **Purpose:** It allows users to execute a checkIn() transaction daily (or per a specific cooldown period). This action records their lastCheckIn timestamp on-chain.

- **Functionality:** This on-chain activity (via the UserCheckedIn event) is monitored by an off-chain service. This service is responsible for calculating rewards for user engagement (e.g., "checked in 7 days in a row").

- **Connection**: Once rewards are calculated, the service calls the assignTokens() function in the Claim Smart Contract to credit the user's account.