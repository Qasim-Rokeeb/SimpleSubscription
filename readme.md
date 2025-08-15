

# 📄 Simple Subscription Smart Contract

A Solidity-based **monthly subscription payment system** that lets users subscribe, renew, and cancel their subscriptions, while giving the contract owner full control over fund withdrawals.

---

## 📌 Overview

The contract is designed to manage **recurring subscription payments** on-chain, using ETH as the payment method.

**Key capabilities:**

* **Users** can:

  * Subscribe by paying a fixed monthly fee.
  * Renew their subscription each month.
  * Cancel their subscription at any time.
* **Owner** can:

  * Withdraw accumulated funds.
  * Set subscription price during deployment.

**Deployed & Verified on Base Sepolia:**
`0x6aCe5ff3dBFb1a9Be27C21eC3db9d39f2dC07655`
🔍 [View Contract on BaseScan](https://sepolia.basescan.org/address/0x6aCe5ff3dBFb1a9Be27C21eC3db9d39f2dC07655#code) ✅

---

## ⚙️ Features

* **Fixed Monthly Fee** — Price set at deployment in **wei**.
* **Automatic Expiration** — Subscriptions expire after **30 days** unless renewed.
* **Active Subscription Check** — Verify subscription status anytime via `isSubscriptionValid`.
* **Event Logging** — All major actions emit events for easy tracking:

  * `SubscriptionCreated`
  * `PaymentMade`
  * `SubscriptionCancelled`
* **Owner Fund Control** — Only the owner can withdraw ETH from the contract.

---

## 🛠 Deployment

### Requirements

* Solidity `^0.8.19`
* Base Sepolia network connection (MetaMask, Hardhat, or Foundry)
* ETH for gas fees

### Deployment Example

```solidity
// Deploy with a monthly price of 0.01 ETH
SimpleSubscription subscription = new SimpleSubscription(0.01 ether);
```

**Constructor:**

```solidity
constructor(uint256 _price)
```

* `_price` — Monthly subscription fee in wei.

---

## 📜 Functions

### **subscribe()** — Create a new subscription

```solidity
function subscribe() external payable
```

* **Requires:** `msg.value == subscriptionPrice`
* **Emits:** `SubscriptionCreated`

---

### **renewSubscription()** — Extend subscription for 30 days

```solidity
function renewSubscription() external payable
```

* **Requires:** Active subscription & exact payment.
* **Emits:** `PaymentMade`

---

### **cancelSubscription()** — End subscription early

```solidity
function cancelSubscription() external
```

* **Requires:** Active subscription.
* **Emits:** `SubscriptionCancelled`

---

### **isSubscriptionValid(address subscriber)** — Check subscription status

```solidity
function isSubscriptionValid(address subscriber) external view returns (bool)
```

* Returns `true` if active within the last 30 days.

---

### **withdraw()** — Owner-only fund withdrawal

```solidity
function withdraw() external
```

* **Access:** Only contract owner.

---

## 🧪 Testing

Run tests locally using Hardhat:

```bash
npm install
npx hardhat test
```

**Example test cases:**

* ✅ Successful subscription creation.
* ✅ Renewal after expiration period.
* ✅ Cancellation by user.
* ✅ Owner fund withdrawal.

---

## 🔍 Verification

Contract verified on Base Sepolia:
[View on BaseScan](https://sepolia.basescan.org/address/0x6aCe5ff3dBFb1a9Be27C21eC3db9d39f2dC07655#code)

---

## 📄 License

MIT License – Free to use and modify.

---

