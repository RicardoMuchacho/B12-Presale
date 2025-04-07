// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract Presale is Ownable {
    using SafeERC20 for IERC20;

    address USDT;
    address USDC;
    address fundReceiver;
    uint256 maxSellingAmount;
    uint256 [][3] phases;
    uint256 startTime;
    uint256 endTime;
    uint256 currentPhase;
    // phases = [[amount, precio, time], [...], [...]]

    mapping (address => bool) public isBlacklisted;
    mapping (address => uint256) public boughtTokens;

    constructor(address USDT_, address USDC_, address fundReceiver_, uint256 maxSellingAmount_, uint256[][3] memory phases_, uint256 startTime_, uint256 endTime_)
    Ownable(msg.sender) {
        USDT = USDT_;
        USDC = USDC_;
        fundReceiver = fundReceiver_;
        maxSellingAmount = maxSellingAmount_;
        phases = phases_;
        startTime = startTime_;
        endTime = endTime_;
        currentPhase = 0;

        require(endTime > startTime, "Incorrect Presale Times");
        require(startTime >= block.timestamp, "Incorrect Start Time");
    }

    /**
    * Function for blacklisting user with only owner access
    * @param user_ the user to blacklist
    */
    function blacklistUser (address user_) external onlyOwner {
        isBlacklisted[user_] = true;
    }

    function removeBlacklist (address user_) external onlyOwner {
        isBlacklisted[user_] = false;
    }

    function emergencyWithdrawERC20 (address tokenAddress_) external onlyOwner {
        uint256 balance = IERC20(tokenAddress_).balanceOf(address(this));
        IERC20(tokenAddress_).safeTransfer(msg.sender, balance);
    }

    function emergencyWithdrawETH () external onlyOwner {
        (bool success ,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
         
    }

    function buyPresaleWithStable(address token_, uint256 amount_) external {
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp >= startTime && block.timestamp < endTime, "Presale hasn't started or has ended");
        require(token_ == USDT || token_ == USDC, "Only USDT and USDC accepted");
        require(amount_ <= maxSellingAmount, "Max amount surpassed"); 
        
        uint256 tokenPrice = phases[currentPhase][1];  
        uint256 tokensToReceive = amount_ / tokenPrice;

        boughtTokens[msg.sender] += tokensToReceive;

    }

    function buyPresaleWithETH() external {
        
    }

}
  