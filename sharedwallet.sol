// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract SharedWallet {
    address public owner = msg.sender;

    mapping (address => uint) public walletUsers;
    uint guardCount;
    uint voteCount = 1;
    struct Guard { 
        uint added;
        uint voted;
    }
    mapping (uint => mapping (address => Guard)) public guardVoted;
    mapping (uint => mapping (address => uint)) public newAddress;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner");
        _;
    }

    event OwnerChanged(address indexed newAddress);
    event VoteCounted(address indexed newOwnerAddress, uint numberOfVotes, address guardAddress);

    receive() external payable { }

    function sendMoney(address payable addressToSend, uint amount) public {
        if(msg.sender == owner){
            require(amount <= address(this).balance, "Not enough money");
            addressToSend.transfer(amount);
        }

        require(walletUsers[addressToSend] >= amount, "No enough amount on the balance");
        walletUsers[addressToSend] -= amount;
        addressToSend.transfer(amount);
    }

    function addWalletUsers(address userAddress, uint amountToSpend) public onlyOwner {
        walletUsers[userAddress] += amountToSpend;
    }

    function checkAmountToSpend(address userAddress) public view returns(uint) {
        return walletUsers[userAddress];
    }

    function setGuards(address guardAddress) public onlyOwner {
        require(++guardCount < 5, "Five guards already exist");
        guardVoted[voteCount][guardAddress] = Guard(1,0);
    }

    function voteForOwner(address newOwnerAddress) public {
        require(newOwnerAddress != owner, "New address need to be different than current");
        require(guardVoted[voteCount][msg.sender].added == 1, "Only guards can voted for new owner");
        require(guardVoted[voteCount][msg.sender].voted == 0, "Guard already voted");

        if (++newAddress[voteCount][newOwnerAddress] >=3){
            owner = newOwnerAddress;
            voteCount ++;
            
            emit OwnerChanged(newOwnerAddress);
        }

        emit VoteCounted(newOwnerAddress, newAddress[voteCount][newOwnerAddress], msg.sender);
    }
}