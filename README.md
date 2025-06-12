# 🌀 YieldMorph

Inspired by Morpho Vaults, YieldMorph is a custom-built DeFi protocol that allows users to earn passive income by depositing DAI tokens into a smart vault. The vault interacts with a lightweight version of Aave (also built from scratch) to lend out tokens, accumulate interest, and manage borrowing/lending securely.

This project is built with Solidity and Foundry, focusing on decentralized finance mechanics, fair interest distribution, and risk-managed withdrawals.

🚀 Features

✅ Vault Deposits

Users can deposit DAI tokens into the Vault contract.

Once deposited, the Vault automatically routes those tokens into the Mini-Aave lending pool.

The Vault keeps track of the user's principal and interest.

💸 Passive Yield

Interest is calculated monthly—users earn interest only for full months.

This avoids complications and manipulations from partial-period interest calculations.

📉 Withdrawals

Users can withdraw their funds anytime, but:

If they withdraw more than 10,000 DAI, a small fee is charged (to discourage whale dumps and promote long-term holding).

🏦 Lending & Borrowing (Mini-Aave)

A custom-built Aave-style lending protocol is integrated:

Users can supply assets to earn interest.

Others can borrow with collateral.

Includes safe loan-to-value logic.



| Layer      | Stack                                                 |
| ---------- | ----------------------------------------------------- |
| Language   | Solidity                                              |
| Framework  | Foundry (forge, cast, anvil)                          |
| Token Used | DAI (ERC20)  , Eth                                    


# Getting Started

Clone the repository
```

git clone <https://github.com/Harisuthan-code/YieldMorph-> cd PushDO---Project

```

# Install OpenZeppelin Contracts


```
forge install OpenZeppelin/openzeppelin-contracts

```


# Compile contracts

```
forge build

```

# Run tests

```
forge test

```
