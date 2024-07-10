// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Banking {
    enum AccountType { Savings, Checking }
    
    struct Account {
        AccountType accountType;
        uint256 balance;
        bool isActive;
    }
    
    address public owner;
    mapping(address => Account) private accounts;

    // Interest rate for Savings accounts (e.g., 5%)
    uint256 public savingsInterestRate = 5;

    // Event to log deposits
    event Deposit(address indexed account, uint256 amount);

    // Event to log withdrawals
    event Withdrawal(address indexed account, uint256 amount);

    // Event to log account transfers
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict certain functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to check if the account is active
    modifier onlyActiveAccount() {
        require(accounts[msg.sender].isActive, "Account is not active");
        _;
    }

    // Function to create an account
    function createAccount(AccountType accountType) public {
        require(!accounts[msg.sender].isActive, "Account already exists");
        accounts[msg.sender] = Account(accountType, 0, true);
    }

    // Function to delete an account (only the owner can delete accounts)
    function deleteAccount(address account) public onlyOwner {
        require(accounts[account].isActive, "Account does not exist");
        accounts[account].isActive = false;
    }

    // Function to deposit Ether into the bank
    function deposit() public payable onlyActiveAccount {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        accounts[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function to withdraw Ether from the bank
    function withdraw(uint256 amount) public onlyActiveAccount {
        require(amount <= accounts[msg.sender].balance, "Insufficient balance");
        accounts[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    // Function to check the balance of the caller
    function getBalance() public view onlyActiveAccount returns (uint256) {
        return accounts[msg.sender].balance;
    }

    // Function to transfer funds between accounts
    function transfer(address to, uint256 amount) public onlyActiveAccount {
        require(accounts[to].isActive, "Recipient account is not active");
        require(amount <= accounts[msg.sender].balance, "Insufficient balance");
        accounts[msg.sender].balance -= amount;
        accounts[to].balance += amount;
        emit Transfer(msg.sender, to, amount);
    }

    // Function to calculate interest for Savings accounts (only the owner can call this)
    function calculateInterest(address account) public onlyOwner {
        require(accounts[account].isActive, "Account is not active");
        require(accounts[account].accountType == AccountType.Savings, "Not a Savings account");
        uint256 interest = (accounts[account].balance * savingsInterestRate) / 100;
        accounts[account].balance += interest;
    }
}
