## Bloque 10 - Swap tokens
---
## Advice:

Router parameters cannot be hardcoded, they should be calculated offChain and passed to the contract as parameters for security reasons.

Mempool: pool of transactions that are waiting to be executed, there is a limit of time we can wait to execute if not it fails in the router

Deadline and minAmount paramters are useful to avoid security attacks

---

## Script

Command to deploy:
forge script [filePath] --rpc-url [rpcUrl chainlist] --broadcast --verify


arb sepholia testnet rpc: https://arbitrum-sepolia.drpc.org

forge script ./script/NftRoyalties.sol --rpc-url https://arbitrum-sepolia.drpc.org --broadcast --verify
