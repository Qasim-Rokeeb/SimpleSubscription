
# 📄 Simple Subscription Smart Contract

A Solidity-based monthly subscription payment system that allows users to subscribe, renew, and cancel their subscriptions while enabling the contract owner to manage funds.

---

## 📌 Overview

This contract enables:

* Users to **subscribe** by paying a fixed monthly fee.
* Users to **renew** subscriptions each month.
* Users to **cancel** subscriptions anytime.
* The contract owner to **withdraw** accumulated funds.

**Deployed & Verified on Base Sepolia:**
[0x6aCe5ff3dBFb1a9Be27C21eC3db9d39f2dC07655](https://sepolia.basescan.org/address/0x6aCe5ff3dBFb1a9Be27C21eC3db9d39f2dC07655#code)

---

## ⚙️ Features

* **One-time monthly fee** stored on deployment.
* **Renewal system** based on timestamps (`30 days` cycle).
* **Active status check** via `isSubscriptionValid` function.
* **Event logging** for all major actions:

  * `SubscriptionCreated`
  * `PaymentMade`
  * `SubscriptionCancelled`
* **Owner-only withdrawal** of contract balance.

---

## 🛠 Deployment

### Requirements

* Solidity `^0.8.19`
* Base Sepolia network connection (via MetaMask, Hardhat, or Foundry)
* ETH balance for deployment gas fees

### Steps

1. Clone this repository.
2. Deploy using Remix, Hardhat, or Foundry with:

   ```solidity
   constructor(uint256 _price)
   ```

   where `_price` is the monthly subscription fee in wei.

Example:

```solidity
SimpleSubscription subscription = new SimpleSubscription(0.01 ether);
```

---

## 📜 Functions

### **subscribe()**

Subscribe to the service by sending the exact subscription fee.

```solidity
function subscribe() external payable
```

* **Requires**: `msg.value == subscriptionPrice`
* **Emits**: `SubscriptionCreated`

---

### **renewSubscription()**

Renew subscription for another month.

```solidity
function renewSubscription() external payable
```

* **Requires**: Active subscription & correct payment.
* **Emits**: `PaymentMade`

---

### **cancelSubscription()**

Cancel current subscription.

```solidity
function cancelSubscription() external
```

* **Requires**: Active subscription.
* **Emits**: `SubscriptionCancelled`

---

### **isSubscriptionValid(address subscriber)**

Check if a subscription is active and within the last 30 days.

```solidity
function isSubscriptionValid(address subscriber) external view returns (bool)
```

---

### **withdraw()**

Withdraw all contract funds (owner only).

```solidity
function withdraw() external
```

---

## 🧪 Testing

To test locally using Hardhat:

```bash
npm install
npx hardhat test
```

Example test scenarios:

* User subscribes successfully.
* Subscription renewal after 30 days.
* Cancelling a subscription.
* Owner withdrawal.

---

## 🔍 Verification

Contract is **verified** on Base Sepolia:
[Base Sepolia Contract Link](https://sepolia.basescan.org/address/0x6aCe5ff3dBFb1a9Be27C21eC3db9d39f2dC07655#code)

---

## 📄 License

MIT License – Free to use and modify.

---

