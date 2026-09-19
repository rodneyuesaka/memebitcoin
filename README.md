# MemeBitcoin (MBTC)

MemeBitcoin (MBTC) is an upgradable ERC-20 token on **BNB Smart Chain (BSC) Mainnet**.
Its entire supply is minted to the token contract at deployment and released on a fixed, halving schedule enforced by on-chain logic, in homage to Bitcoin's monetary policy.

---

## Token Details

| Detail               | Value                                                        |
|----------------------|--------------------------------------------------------------|
| **Network**          | BNB Smart Chain (chain id 56)                                |
| **Website**          | https://memebitcoin.org                                      |
| **Upgrade Standard** | UUPS (ERC-1967 proxy)                                        |
| **Total Supply**     | 210,000,000,000 MBTC, minted once at deployment              |
| **Decimals**         | 8                                                            |
| **Release Start**    | 2026-01-03 18:15:05 UTC (`1767464105`)                       |
| **Release Interval** | 10 minutes                                                   |
| **Halving Period**   | 122 days (17,568 releases per cycle)                         |

---

## Contract Addresses (BSC Mainnet)

| Contract | Address | Status |
|:---------|:--------|:-------|
| **Token (proxy)** | [0x3b93314430A7db7d614eB3A6c226dEa01973d0Ef](https://bscscan.com/token/0x3b93314430A7db7d614eB3A6c226dEa01973d0Ef) | **Active** |
| Token (implementation) | [0x54CB3dD5284041Bd1207be034AF95cCcBF71EF22](https://bscscan.com/address/0x54CB3dD5284041Bd1207be034AF95cCcBF71EF22#code) | Active |
| Claim | [0xeE53735Ca6660aB261A07abfbCA7CA66e56a70A4](https://bscscan.com/address/0xeE53735Ca6660aB261A07abfbCA7CA66e56a70A4) | Retired (2026-09-19) |

Source code for both the token proxy and its implementation is verified on BscScan.

---

## Release Schedule

- The full supply sits in the token contract and is released every 10 minutes by `releaseTokens()`.
- The first cycle releases half of the supply evenly: `(210,000,000,000 / 2) / 17,568` MBTC per release. Each subsequent 122-day cycle halves the per-release amount.
- Each release moves the scheduled amount from the token contract to the address stored in `distributionContract`.
- If releases fall behind schedule, later calls catch up one period per call, so the schedule itself does not drift.
- Integer division leaves a small remainder after many halvings. That remainder stays in the token contract.

### Permissionless release

`releaseTokens()` has no access control. Any account or bot can call it once the next release time has passed, so emission continues without relying on the project team. The caller cannot choose where tokens go: they always go to `distributionContract`.

---

## Governance

The token has a single privileged role, the **owner**. The owner is a Safe smart account. You can read it on BscScan under *Contract → Read as Proxy → `owner`*.

The owner can do exactly two things:

1. **Change the release destination** with `setDistributionContract(address)`. The current destination is readable as `distributionContract`.
2. **Upgrade the implementation** through UUPS (`upgradeToAndCall`).

The owner cannot mint, burn, pause transfers, or move tokens held by others. There is no mint function after deployment.

---

## Build

| Item | Value |
|------|-------|
| Compiler | solc 0.8.24 |
| Optimizer | enabled, 200 runs |
| Libraries | OpenZeppelin Contracts Upgradeable 5.4.0 |

`contracts/MbtcBscTokenUpgradable.sol` in this repository is byte-identical to the verified source of the deployed implementation.

---

## History

| Date | Change |
|------|--------|
| 2026-01-03 | v1.0.0 live on mainnet. Releases start. |
| 2026-08-22 | Token name updated to **MemeBitcoin** through a one-time `initializeV2` (reinitializer 2). |
| 2026-09-19 | Release destination changed from the Claim contract to a Safe smart account. Ownership transferred to a Safe smart account. The Claim contract was retired and its balance moved to the same Safe. |

The Check-in and Donation contracts are no longer maintained in this repository. Earlier versions remain in the git history.
