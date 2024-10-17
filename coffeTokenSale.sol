// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

abstract contract ERC20 {
    function transferFrom(address _addressFrom, address _to, uint value) public virtual returns(bool success);
    function decimals() public virtual view returns(uint8);
}

contract TokenSale {
    uint public tokenPrice = 1 ether;
    ERC20 public token;
    address public owner = msg.sender;

    constructor (address _token) {
        token = ERC20(_token);
    }

    function purchaseToken() public payable {
        require(msg.value >= tokenPrice, "Not enough money");
        uint tokenToTransfer = msg.value / tokenPrice;
        uint remainder = msg.value - tokenToTransfer * tokenPrice;
        token.transferFrom(owner, msg.sender, tokenToTransfer);
        payable(msg.sender).transfer(remainder);
    }
}