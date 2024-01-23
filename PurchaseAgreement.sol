// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract PurchaceAgreement {
    uint public price;
    address payable public seller;
    address payable public buyer;
    enum State {
        Created,
        Locked,
        Release,
        Inactive
    }

    State public state;

    constructor() payable {
        seller = payable(msg.sender);
        price = msg.value;
    }

    /// The function cannot be called at the current state.
    error InvalidState();
    /// Only the buyer is allowed to perform this action
    error OnlyBuyer();
    /// Only the seller is allowed to perform this action
    error OnlySeller();

    modifier inState(State state_) {
        if (state != state_) {
            revert InvalidState();
        }
        _;
    }

    modifier onlyBuyer() {
        if (msg.sender != buyer) {
            revert OnlyBuyer();
        }
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller) {
            revert OnlySeller();
        }
        _;
    }

    function confirmPurchase() external payable inState(State.Created) {
        require(
            msg.value == (2 * price),
            "2x of the amount is required to be sent in order to confirm your purchase"
        );
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state = State.Release;
        buyer.transfer(price);
    }

    function receivePayment() external onlySeller inState(State.Release) {
        state = State.Inactive;
        seller.transfer(2 * price);
    }

    function abort() external onlySeller inState(State.Created) {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}
