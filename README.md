# **DeFi Algo Trading Smart Contract**

## **Overview**
This project implements an **algorithmic trading strategy** using Ethereum smart contracts. The strategy involves:
1. Converting ETH to WETH.
2. Swapping WETH for USDC on Uniswap.
3. Supplying USDC,WETH to the Aave protocol to earn interest.
4. Withdrawing USDC,WETH from the Aave protocol.

The smart contract is designed to allow users to interact with it and execute this strategy seamlessly in a decentralized manner.

---

## **Features**
- **ETH to WETH Conversion**: Wraps ETH into WETH for ERC-20 compatibility.
- **Uniswap Integration**: Swaps WETH for USDC using Uniswap's V3 router.
- **Aave Integration**: Supplies USDC to Aave's lending pool to earn interest.
- **Balance Tracking**: Allows users to check their WETH, USDC, and aUSDC balances.
- **Modular Design**: Each step of the strategy is implemented as a separate function for flexibility.

---

## **Technologies Used**
- **Solidity (v0.8.20)**: Smart contract programming language.
- **Uniswap V3**: Decentralized exchange for token swaps.
- **Aave V3**: Lending and borrowing protocol for earning interest on deposits.
- **Foundry**: Development framework for testing and deploying smart contracts.

---

## **Smart Contract Architecture**

### **Contracts**
1. `AlgoTrading.sol`:
   - Core contract implementing the trading strategy.
2. `InteractAlgoTrading.sol`:
   - Script for interacting with the deployed `AlgoTrading` contract.

### **Key Functions**
#### 1. `swapEthForWeth()`
Wraps ETH into WETH using the WETH contract.

#### 2. `swapWethForUsdc(uint amountIn)`
Swaps a specified amount of WETH for USDC using Uniswap V3.

#### 3. `supplyUSDCToAave(uint256 amountIn)`
Supplies USDC to Aave's lending pool and mints aUSDC tokens for the user.

#### 4. `getATokenBalance()`
Fetches the user's aUSDC balance from Aave, confirming successful deposits.

#### 5. `getTokenBalances()`
Returns the user's WETH and USDC balances.

---

## **Setup Instructions**

### Prerequisites
- Node.js and npm installed
- Foundry installed (`forge` and `anvil`)
- An Ethereum RPC URL (e.g., Infura or Alchemy)

### Installation
1. Clone the repository:

2. Install dependencies:


3. Set up environment variables:
- Create a `.env` file with the following variables:
  ```
  RPC_URL=<your_rpc_url>
  PRIVATE_KEY=<your_private_key>
  ```

4. Compile the contracts:

5. Run tests:

---

## **Deployment**
1. Start an Anvil fork of Ethereum Mainnet:
anvil --fork-url <RPC_URL> --hardfork shanghai


2. Deploy the smart contract:
forge script script/Deploy.s.sol --broadcast --rpc-url <RPC_URL> --private-key .env.PRIVATE_KEY

3. Note down the deployed contract address from the terminal output.

---

## **Usage**

### Interact with the Contract
Use the provided script (`InteractAlgoTrading.sol`) to interact with your deployed contract:

1. Check initial balances:

2. Execute the trading strategy step-by-step:
- Convert ETH to WETH.
- Swap WETH for USDC.
- Supply USDC to Aave.
- Withdraw assets from Aave.

3. Verify balances after each step using the console logs 

---

## **Example Workflow**

1. Deposit 1 ETH into the contract:
 - Call `swapEthForWeth()` with 1 ETH sent as value.

2. Swap WETH for USDC:
 - Call `swapWethForUsdc()` with the desired amount of WETH.

3. Supply USDC,WETH to Aave:
 - Call `supply` functions.

4. Withdraw USDC,WETH from Aave:
 - Call `withdraw` functions.
---

## **Contracts and Addresses**

| Contract         | Address (Mainnet)                                      |
|------------------|-------------------------------------------------------|
| WETH             | `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`          |
| USDC             | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`          |
| Uniswap Router V3| `0xE592427A0AEce92De3Edee1F18E0157C05861564`          |
| Aave Pool        | `0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2`          |
| Aave Data Provider | `0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d`        |

---

## **Future Improvements**
- Add support for multiple trading strategies.
- Implement stop-loss, take-profit,rebalancing mechanisms.
- Integrate additional DeFi protocols like Compound or Curve.
- Support gas optimization techniques like batch transactions.

---

## **License**
This project is licensed under [MIT License](LICENSE).