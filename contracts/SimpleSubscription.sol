// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// =============================================================================
// PROJECT 19: Simple Subscription - Monthly subscription payments
// =============================================================================

contract SimpleSubscription {
    struct Subscription {
        address subscriber;
        uint256 price;
        uint256 lastPayment;
        bool isActive;
    }
    
    mapping(address => Subscription) public subscriptions;
    address public owner;
    uint256 public subscriptionPrice;
    uint256 public constant MONTH_SECONDS = 30 days;
    
    event SubscriptionCreated(address indexed subscriber, uint256 price);
    event PaymentMade(address indexed subscriber, uint256 amount);
    event SubscriptionCancelled(address indexed subscriber);
    
    constructor(uint256 _price) {
        owner = msg.sender;
        subscriptionPrice = _price;
    }
    
    function subscribe() external payable {
        require(msg.value == subscriptionPrice, "Incorrect payment amount");
        
        subscriptions[msg.sender] = Subscription({
            subscriber: msg.sender,
            price: subscriptionPrice,
            lastPayment: block.timestamp,
            isActive: true
        });
        
        emit SubscriptionCreated(msg.sender, subscriptionPrice);
    }
    
    function renewSubscription() external payable {
        require(subscriptions[msg.sender].isActive, "No active subscription");
        require(msg.value == subscriptionPrice, "Incorrect payment amount");
        
        subscriptions[msg.sender].lastPayment = block.timestamp;
        
        emit PaymentMade(msg.sender, msg.value);
    }
    
    function cancelSubscription() external {
        require(subscriptions[msg.sender].isActive, "No active subscription");
        
        subscriptions[msg.sender].isActive = false;
        
        emit SubscriptionCancelled(msg.sender);
    }
    
    function isSubscriptionValid(address subscriber) external view returns (bool) {
        Subscription memory sub = subscriptions[subscriber];
        return sub.isActive && (block.timestamp - sub.lastPayment) <= MONTH_SECONDS;
    }
    
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
