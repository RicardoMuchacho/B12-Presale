// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../src/Presale.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SwapTest is Test {
    Presale public presale;
    address user = vm.addr(1);
    address devUser = 0xc717879FBc3EA9F770c0927374ed74A998A3E2Ce;
    address arbUser = 0x41acf0e6eC627bDb3747b9Ed6799c2B469F77C5F;

    address constant arbRouter2 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    string constant ARBITRUM_RPC = "https://arb1.arbitrum.io/rpc";
    uint256 public constant FORK_BLOCK = 321250277;

    function setUp() public {
        vm.createSelectFork(ARBITRUM_RPC, FORK_BLOCK);
        // presale = new Presale(arbRouter2);
    }

    function test_isDeployedCorrectly() public view {
        // assert(presale.V2Router02Address() == arbRouter2);
    }
}
