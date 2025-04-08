// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../src/Presale.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    uint256 private _totalSupply = 30_000_000 * 1e18;

    constructor() ERC20("Mock Token", "MT") {
        _mint(msg.sender, _totalSupply);
    }
}

contract PresaleTest is Test {
    Presale public presale;
    MockToken public mockToken;
    address fundsReceiver = vm.addr(1);
    address user = vm.addr(2);
    address owner = vm.addr(3);
    address devUser = 0xc717879FBc3EA9F770c0927374ed74A998A3E2Ce;
    address arbUser = 0x41acf0e6eC627bDb3747b9Ed6799c2B469F77C5F;

    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    string constant ARBITRUM_RPC = "https://arb1.arbitrum.io/rpc";
    uint256 public constant FORK_BLOCK = 321250277;

    address _dataFeedAddress = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    uint256 _maxSellingAmount = 30_000_000 * 1e18;
    uint256[][3] public _phases;

    function setUp() public {
        vm.createSelectFork(ARBITRUM_RPC, FORK_BLOCK);
        vm.startPrank(owner);

        _phases = [
            [10_000_000 * 1e18, 0.005 * 1e6, block.timestamp + 1000],
            [10_000_000 * 1e18, 0.05 * 1e6, block.timestamp + 1000],
            [10_000_000 * 1e18, 0.5 * 1e6, block.timestamp + 1000]
        ];
        mockToken = new MockToken();

        presale = new Presale(
            address(mockToken),
            _dataFeedAddress,
            USDT,
            USDC,
            fundsReceiver,
            _maxSellingAmount,
            _phases,
            block.timestamp,
            block.timestamp + 3000
        );

        mockToken.approve(address(presale), _maxSellingAmount);
        presale.getPresaleTokens();
        vm.stopPrank();

    }

    function test_isDeployedCorrectly() public view {
        assertEq(presale.tokenAddress(), address(mockToken));
        assertEq(mockToken.balanceOf(address(presale)), _maxSellingAmount);
    }

    function test_blacklistCorrectly() public {
        vm.startPrank(owner);
        presale.blacklistUser(user);
        assertEq(presale.isBlacklisted(user), true);
        vm.stopPrank();
    }

    function test_removeBlacklistCorrectly() public {
        vm.startPrank(owner);

        presale.blacklistUser(user);
        assertEq(presale.isBlacklisted(user), true);
        presale.removeBlacklist(user); 
        assertEq(presale.isBlacklisted(user), false);

        vm.stopPrank();
    }

    function test_getETHPriceCorrectly() public view {
        uint256 price = presale.getETHPrice();
        assertGt(price, 1e18);
    }

    function test_emergencyWithdrawERC20() public {
        uint256 USDTAmount = 10*1e6; // 10 USDT
        vm.startPrank(arbUser);
        IERC20(USDT).transfer(address(presale), USDTAmount);
        vm.stopPrank();

        vm.startPrank(owner);
        
        uint256 USDTBalanceBefore = IERC20(USDT).balanceOf(address(presale));
 
        presale.emergencyWithdrawERC20(USDT);

        uint256 USDTBalanceAfter = IERC20(USDT).balanceOf(address(presale));
       
        assertEq(USDTBalanceBefore, USDTBalanceAfter + USDTAmount);
        vm.stopPrank();
    }

    function test_emergencyWithdrawETH() public {
        uint256 ethAmount = 1 ether;
        vm.deal(address(presale), ethAmount);
        vm.startPrank(owner);
        
        uint256 ETHBalanceBefore = address(presale).balance;
 
        presale.emergencyWithdrawETH();

        uint256 ETHBalanceAfter = address(presale).balance;
       
        assertEq(ETHBalanceBefore, ETHBalanceAfter + ethAmount);
        vm.stopPrank();
    }

    function test_buyPresalePhase1WithStable() public {
        uint256 purchaseAmount = 10 * 1e6; // 10 USDT
        vm.startPrank(arbUser);
        
        IERC20(USDT).approve(address(presale), purchaseAmount);
        uint256 balanceReceiverBefore = IERC20(USDT).balanceOf(fundsReceiver);        

        presale.buyPresaleWithStable(USDT, purchaseAmount);

        uint256 expectedTokens = purchaseAmount * 1e18 / _phases[0][1];
        uint256 balanceReceiverAfter = IERC20(USDT).balanceOf(fundsReceiver);

        assertEq(presale.userClaimableTokens(arbUser), expectedTokens);
        assertEq(balanceReceiverAfter, balanceReceiverBefore + purchaseAmount);
        vm.stopPrank();
    }

    function test_revertBuyPresaleStableIfBlacklisted() public {
        vm.startPrank(owner);
        presale.blacklistUser(arbUser);
        vm.stopPrank();

        uint256 purchaseAmount = 10 * 1e6; // 10 USDT
        vm.startPrank(arbUser);
        
        IERC20(USDT).approve(address(presale), purchaseAmount);
           
        vm.expectRevert("User is blacklisted");
        presale.buyPresaleWithStable(USDT, purchaseAmount);

        vm.stopPrank();
    }

    function test_revertBuyPresaleStableNotStarted() public {
        uint256 purchaseAmount = 10 * 1e6; // 10 USDT
        vm.startPrank(arbUser);
        
        IERC20(USDT).approve(address(presale), purchaseAmount);
        vm.warp(block.timestamp - 10);
        vm.expectRevert("Presale hasn't started or has ended");
        presale.buyPresaleWithStable(USDT, purchaseAmount);

        vm.stopPrank();
    }

    function test_revertBuyPresaleStableIfTokenNotAccepted() public {
        uint256 purchaseAmount = 10 * 1e6; // 10 USDT
        vm.startPrank(arbUser);
        
        IERC20(DAI).approve(address(presale), purchaseAmount);
           
        vm.expectRevert("Only USDT and USDC accepted");
        presale.buyPresaleWithStable(DAI, purchaseAmount);

        vm.stopPrank();
    }

    function test_buyPresalePhase2WithETH() public {
        uint256 purchaseAmount = 0.0001 ether;
        vm.deal(arbUser, purchaseAmount);
        vm.startPrank(arbUser);
    
        uint256 ETHPrice = presale.getETHPrice();
        
        uint256 balanceReceiverBefore = fundsReceiver.balance;        
        uint256 expectedTokens = (purchaseAmount * ETHPrice) / (_phases[0][1] * 1e12);
     
        vm.warp(block.timestamp + 1001);
        presale.buyPresaleWithETH{value: purchaseAmount}();

        uint256 balanceReceiverAfter = fundsReceiver.balance;        

        assertEq(presale.userClaimableTokens(arbUser), expectedTokens);
        assertEq(balanceReceiverAfter, balanceReceiverBefore + purchaseAmount);
        vm.stopPrank();
    }

    function test_revertBuyPresaleWithETHIfBlacklisted() public {
        vm.startPrank(owner);
        presale.blacklistUser(arbUser);
        vm.stopPrank();

        uint256 purchaseAmount = 0.0001 ether;
        vm.deal(arbUser, purchaseAmount);
        vm.startPrank(arbUser);
         
        vm.expectRevert("User is blacklisted");
        presale.buyPresaleWithETH{value: purchaseAmount}();

        vm.stopPrank();
    }

    function test_revertBuyPresaleETHStableNotStarted() public {
        uint256 purchaseAmount = 0.0001 ether;
        vm.deal(arbUser, purchaseAmount);
        vm.startPrank(arbUser);
        
        vm.warp(block.timestamp - 10);
        vm.expectRevert("Presale hasn't started or has ended");
        presale.buyPresaleWithETH{value: purchaseAmount}();

        vm.stopPrank();
    }

    function test_claimTokens() public {
        uint256 purchaseAmount = 10 * 1e6; // 10 USDT
        vm.startPrank(arbUser);
        
        IERC20(USDT).approve(address(presale), purchaseAmount);

        presale.buyPresaleWithStable(USDT, purchaseAmount);

        vm.warp(block.timestamp + 3001);
        uint256 claimableTokensBefore = presale.userClaimableTokens(arbUser);        

        presale.claimTokens();

        uint256 balanceAfter = IERC20(mockToken).balanceOf(arbUser);        
        uint256 claimableTokensAfter = presale.userClaimableTokens(arbUser);        

        assertEq(balanceAfter, claimableTokensBefore);
        assertEq(claimableTokensAfter, 0);

        vm.stopPrank();
    }
}