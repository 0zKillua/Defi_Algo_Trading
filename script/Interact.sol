// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/algo.sol";


contract InteractAlgoTrading is Script{
    
    address constant WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    address constant aEthUSDC=0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c;
    address constant aEthWETH=0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8;
    address constant algoTradingAdd=0x53E4DAFF2073f848DC3F7a8D7CC95b3607212A73;

    function run() external{
        vm.startBroadcast();
    
    AlgoTrading  algoTrading= AlgoTrading(payable(algoTradingAdd)); //add deployed contract address
    
    //check initial balances:
    console.log("############ Initial Balances of user");
    getTokenBalances(msg.sender);
  
    console.log("############ Initial Balances of algo contract");
    getTokenBalances(algoTradingAdd);
    
    //STEP 1: 
    uint amount=10 ether;
    
    console.log("10 eth from user -----> 10 WETH to algo");
    algoTrading.swapEthforWeth{value: amount }();
    
    IWETH weth = IWETH(WETH);


    // STEP 2: 
    
    weth.approve(address(algoTradingAdd), amount);

    uint256 amountOut=algoTrading.swapWethForUsdc(1 ether);
    console.log("1 WETH swap from algo --> USDC to user ", amountOut);

    console.log("##### after swap balances of user ####");
    getTokenBalances(msg.sender);
    
    // STEP 3 :
   
   //send usdc to algoTrading contract
   uint usdcBalance=IERC20(USDC).balanceOf(address(msg.sender));
    IERC20(USDC).transfer(address(algoTrading), usdcBalance);
    console.log("all USDC transfer from user --> algo ");
    usdcBalance = IERC20(USDC).balanceOf(address(algoTrading));
    console.log("after transfer  USDC Balance of contract:", usdcBalance);
    uint256 Wethbalance = IERC20(WETH).balanceOf(address(algoTrading));
    console.log(" Weth Balance of contract:", Wethbalance);
    
    //supply 1000 usdc to aave
    console.log("############# supply 1000 USDC to AAVE########");
    algoTrading.supplyUSDCToAave(1000 * 10 ** 6);

    console.log("############# supply 3 WETH to AAVE########");

    algoTrading.supplyWethtoAave(3 * 10**18);

    // address ausdToken=algoTrading.getAllATokens("aEthUSDC");
    // address awethToken=algoTrading.getAllATokens("aEthWETH");
    // console.log("ausd ",ausdToken);

    
    
    uint aEthUSDCbal=IERC20(aEthUSDC).balanceOf(msg.sender);
    console.log("aEthUSDC balance of user is ",aEthUSDCbal);
    uint aEthWETHbal=IERC20(aEthWETH).balanceOf(msg.sender);
    console.log("aETHWETh balance of user is  ",aEthWETHbal);

    console.log("for withDraw ###  aTokens transfer from user ----> algo ");
    
    IERC20(aEthUSDC).transfer(algoTradingAdd,500 * 10 ** 6);
    IERC20(aEthWETH).transfer(algoTradingAdd,3 * 10 ** 18);

    console.log("withdraw 100 USDC , 2 WETH from AAVE");
    algoTrading.withdrawUSDCfromAave(100 * 10**6);
    algoTrading.withdrawWethfromAave(2 * 10**18);
    console.log("######## post balances of user ########");
    getTokenBalances(msg.sender);
    
    console.log("######## post balances of algo contract ########");
    getTokenBalances(algoTradingAdd);
   
      vm.stopBroadcast();
    }

    function getTokenBalances(address user) internal view {
    uint wethBalance=IERC20(WETH).balanceOf(user);
    uint usdcBalance=IERC20(USDC).balanceOf(user);
    uint aEthUSDCBalance=IERC20(aEthUSDC).balanceOf(user);
    uint aEthWETHBalance=IERC20(aEthWETH).balanceOf(user);

    console.log("WETH Balance: ", wethBalance);
    console.log("USDC Balance: ", usdcBalance);
    console.log("aEthUSDCBal: ",aEthUSDCBalance);
    console.log("aEthWETHBal: ",aEthWETHBalance);
    }

}