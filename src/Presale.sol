// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";
import "./IAgregator.sol";

contract Presale is Ownable {
    using SafeERC20 for IERC20;

    address public tokenAddress;
    address public USDT;
    address public USDC;
    address public fundsReceiver;
    address public dataFeedAddress;
    uint256 public maxSellingAmount;
    uint256[][3] public phases;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalSold;
    uint256 public currentPhase;
    // phases = [[amount, precio, time], [...], [...]]

    mapping(address => bool) public isBlacklisted;
    mapping(address => uint256) public userClaimableTokens;

    struct phase {
        uint256 amount;
        uint256 price;
        uint256 time;
    }

    event tokensSold(address indexed buyer, uint256 indexed stableAmount);
    event tokensClaimed(address indexed user, uint256 indexed tokenAmount);
    constructor(
        address tokenAddress_,
        address dataFeedAddress_,
        address USDT_,
        address USDC_,
        address fundsReceiver_,
        uint256 maxSellingAmount_,
        uint256[][3] memory phases_,
        uint256 startTime_,
        uint256 endTime_
    ) Ownable(msg.sender) {
        tokenAddress = tokenAddress_;
        USDT = USDT_;
        USDC = USDC_;
        fundsReceiver = fundsReceiver_;
        dataFeedAddress = dataFeedAddress_;
        maxSellingAmount = maxSellingAmount_;
        phases = phases_;
        startTime = startTime_;
        endTime = endTime_;
        currentPhase = 0;

        require(endTime > startTime && startTime >= block.timestamp, "Incorrect Presale Times");

        IERC20(tokenAddress_).safeTransferFrom(msg.sender, address(this), maxSellingAmount);
    }

    /**
     * Function for blacklisting user with only owner access
     * @param user_ the user to blacklist
     */
    function blacklistUser(address user_) external onlyOwner {
        isBlacklisted[user_] = true;
    }

    function removeBlacklist(address user_) external onlyOwner {
        isBlacklisted[user_] = false;
    }

    function getETHPrice() public view returns (uint256 price){
        (, int256 ETHPrice , , ,) = IAgregator(dataFeedAddress).latestRoundData(); // Uses chainlink data feed to get ETH price
        price = uint256(ETHPrice * 1e10); // chainlink returns a 8 decimals int
    }

    function emergencyWithdrawERC20(address tokenAddress_) external onlyOwner {
        uint256 balance = IERC20(tokenAddress_).balanceOf(address(this));
        IERC20(tokenAddress_).safeTransfer(msg.sender, balance);
    }

    function emergencyWithdrawETH() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    /**
     * Function to buy presale tokens with stable coins
     * @param token_ address of token used to buy
     * @param amount_ amount of tokens
     */
    function buyPresaleWithStable(address token_, uint256 amount_) external {
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp >= startTime && block.timestamp < endTime, "Presale hasn't started or has ended");
        require(token_ == USDT || token_ == USDC, "Only USDT and USDC accepted");

        uint256 tokenPrice = phases[currentPhase][1];
        uint256 decimals = ERC20(token_).decimals();

        // formula to always get 18 decimals tokens
        uint256 tokensToReceive = amount_ * 10 ** (18 - decimals) * 1e6 / tokenPrice; // Ej x=2: 2 + 16 + 6 - 6

        totalSold += tokensToReceive;
        require(totalSold <= maxSellingAmount, "Sold out");

        userClaimableTokens[msg.sender] += tokensToReceive;

        //Receive user tokens
        IERC20(token_).safeTransferFrom(msg.sender, fundsReceiver, amount_);

        emit tokensSold(msg.sender, amount_);
    }

    function buyPresaleWithETH() external payable {
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp >= startTime && block.timestamp < endTime, "Presale hasn't started or has ended");


        uint256 ETHPrice = getETHPrice();
        uint256 USDValue = msg.value * ETHPrice;
        uint256 tokenPrice = phases[currentPhase][1];

        uint256 tokensToReceive = USDValue * 1e6 / tokenPrice; // 18 + 6 - 6 = 18 decimals
        checkCurrentPhase();

        totalSold += tokensToReceive;
        require(totalSold <= maxSellingAmount, "Sold out");

        userClaimableTokens[msg.sender] += tokensToReceive;

        //Receive user tokens
        (bool success,) = fundsReceiver.call{value: msg.value}("");
        require(success, "Transactiion fail");

        emit tokensSold(msg.sender, USDValue);
    }

    function claimTokens() external {
        uint256 userTokens = userClaimableTokens[msg.sender];

        require(userTokens > 0, "No tokens bought");
        require(block.timestamp > endTime, "Presale hasn't ended");

        delete userClaimableTokens[msg.sender];

        IERC20(tokenAddress).safeTransferFrom(address(this), msg.sender, userTokens);

        emit tokensClaimed(msg.sender, userTokens);
    }

    function checkCurrentPhase() private returns (uint256 currentPhase_) {
        if ((block.timestamp >= phases[currentPhase][2] && currentPhase < 3) || (totalSold > phases[currentPhase][0])) {
            currentPhase++;
            currentPhase_ = currentPhase;
        } else {
            currentPhase_ = currentPhase;
        }
    }
}
