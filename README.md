# 🔄 SwapApp - Uniswap V2 Router Integration on Arbitrum One

## 📌 Overview
SwapApp is a Solidity smart contract that integrates Uniswap's V2 Router to enable seamless token swaps and liquidity management on the Arbitrum One mainnet. The contract supports swaps between ERC-20 tokens and ETH, as well as adding and removing liquidity from Uniswap pools.

## 🔍 Contract

- **Arbiscan:** [View and interact with the contract](https://arbiscan.io/address/0xA4b3f7783E1a48A5D06df273Ba00D7F6D40B0291#code) on Arbiscan.

---

## ✨ Key Features
- **Uniswap V2 Integration**: Uses Uniswap V2 Router for decentralized swaps and liquidity management.
- **100% Test Coverage**: Ensures reliability and security.
- **Token-to-Token Swaps**: Swap one ERC-20 token for another.
- **ETH to Token Swaps**: Convert ETH to ERC-20 tokens.
- **Token to ETH Swaps**: Convert ERC-20 tokens to ETH.
- **Add Liquidity**: Provide liquidity to Uniswap V2 pools and receive LP tokens.
- **Remove Liquidity**: Withdraw liquidity from Uniswap V2 pools and receive corresponding tokens.

## 📜 Contracts Overview

| Contract  | Description |
|-----------|------------|
| `IV2Router` | Interface for interacting with Uniswap V2 Router functions. |
| `IV2Factory` | Interface for interacting with Uniswap V2 Factory. |
| `SwapApp` | Implements token swaps, ETH conversions, and liquidity management using Uniswap V2 Router. |

### ⚙️ `SwapApp.sol` Contract Functions

#### **Swaps**
| Function | Description |
|----------|------------|
| `swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_)` | Swaps ERC-20 tokens for another ERC-20 token. |
| `swapETHForTokens(uint256 amountOutMin_, address[] memory path_, uint256 deadline_)` | Swaps ETH for ERC-20 tokens. |
| `swapTokensForETH(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_)` | Swaps ERC-20 tokens for ETH. |
| `getAmountOutHelper(uint256 amountIn_, address[] calldata path_)` | Helper function to fetch estimated output amount for a given input amount. |

#### **Liquidity Management**
| Function | Description |
|----------|------------|
| `addLiquidityWithTokenA(uint256 amountIn_, address[] memory path_, uint256 amountOutMin_, uint256 amountAMin_, uint256 amountBMin_, uint256 deadline_)` | Adds liquidity to Uniswap V2 pools using Token A. The function swaps half the input amount to Token B before adding liquidity. |
| `removeLiquidity(address tokenA_, address tokenB_, uint256 amountAMin_, uint256 amountBMin_, uint256 deadline_)` | Removes liquidity from Uniswap V2 pools and returns the respective token amounts to the user. |

## 🚀 Getting Started
1. Deploy `SwapApp` with the Uniswap V2 Router address on Arbitrum One.
2. Ensure that users approve token transfers before swapping or adding liquidity.
3. Call the relevant swap or liquidity function depending on the desired action.

## 📝 Events
| Event | Description |
|----------|------------|
| `tokenSwap(address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut)` | Emitted when a user swaps tokens. |
| `ETHForTokensSwap(address indexed user, address indexed tokenOut, uint256 amountIn, uint256 amountOut)` | Emitted when a user swaps ETH for tokens. |
| `tokensForETHSwap(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut)` | Emitted when a user swaps tokens for ETH. |
| `liquidityAdded(address indexed user, address tokenA, address tokenB, uint256 indexed liquidity)` | Emitted when liquidity is added to a Uniswap V2 pool. |
| `liquidityRemoved(address indexed user, address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB)` | Emitted when liquidity is removed from a Uniswap V2 pool. |

