// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "./IERC20.sol";
import "./IPool.sol"; //aave pool

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function balanceOf(address ) external view returns (uint256);
    function approve(address,uint) external returns(uint256);
}

//Uniswap
interface ISwapRouter  {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
        function exactInputSingle(ExactInputSingleParams calldata) external payable returns (uint256 );

}

interface IProtocolDataProvider{
    function getUserReserveData(address asset,address user) external returns(
        uint256 currentATokenBalance,
    uint256 currentStableDebt,
    uint256 currentVariableDebt,
    uint256 principalStableDebt,
    uint256 scaledVariableDebt,
    uint256 stableBorrowRate,
    uint256 liquidityRate,
    uint40 stableRateLastUpdated,
    bool usageAsCollateralEnabled
    );
    function getReserveConfigurationData(address asset) external returns(
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus,
    uint256 decimals,
    uint256 reserveFactor,
    bool isActive,
    bool isFrozen,
    bool borrowingEnabled,
    bool stableBorrowRateEnabled,
    bool paused);

    struct TokenData{
        string symbol;
        address token;
    }

function getAllATokens() external view returns (TokenData[] memory);

}

interface IPoolAddressProvider{
    function getPool() external view returns (address);
    function getPoolDataProvider() external view returns (address);

}



contract AlgoTrading {

    
    address constant USDC=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant SWAP_ROUTER=0xE592427A0AEce92De3Edee1F18E0157C05861564;
    uint24 public constant feeTier = 3000; //swap fee

    address AAVE_DATA_PROVIDER=0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d;
    address AAVE_POOL_ADD_PROVIDER=0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
    address aave_pool;
    address aEthUSDC=0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c;
    address aETHWETH=0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8;
   

    struct TokenData{
        string symbol;
        address token;
    }
    
    function swapWethForUsdc(uint amountIn) external returns(uint amountOut){
            // TransferHelper.safeTransferFrom(WETH, msg.sender, address(this), amountIn);
            
            // TransferHelper.safeApprove(WETH, address(SWAP_ROUTER), amountIn);
            IWETH(WETH).approve(address(SWAP_ROUTER),amountIn);

            uint256 minOut = /* Calculate min output */ 0;
            uint160 priceLimit = /* Calculate price limit */ 0;
            // Create the params that will be used to execute the swap
            ISwapRouter.ExactInputSingleParams memory params =
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: WETH,
                    tokenOut: USDC,
                    fee: feeTier,
                    recipient: msg.sender,
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: minOut,
                    sqrtPriceLimitX96: priceLimit
                });
        // The call to `exactInputSingle` executes the swap.
            ISwapRouter  swapRouter = ISwapRouter(SWAP_ROUTER);

            amountOut = swapRouter.exactInputSingle(params);


    }

    function swapEthforWeth() public payable{

        IWETH  weth=IWETH(WETH);
        require(msg.value > 0,"send some ETH");
        weth.deposit{value: msg.value}();

        //If you want to transfer weth back to user
        //  weth.transfer(msg.sender, msg.value);

    }

    function supplyUSDCToAave(uint256 amountIn) external{
        require(amountIn > 0, "Amount must be greater than zero");
         aave_pool= getPool();

        IERC20(USDC).approve(aave_pool, amountIn);

        IPool(aave_pool).supply(USDC,amountIn,msg.sender,0);

    }

    function withdrawUSDCfromAave(uint256 amountOut) external{
        //require 
        aave_pool= getPool();
        IERC20(aEthUSDC).approve(aave_pool,amountOut);
        IPool(aave_pool).withdraw(USDC,amountOut,msg.sender);

    }

    function supplyWethtoAave(uint256 amountWeth) external{
        require(amountWeth > 0, "Amount must be greater than zero");
        
         aave_pool= getPool();
        IERC20(WETH).approve(aave_pool,amountWeth);
        IPool(aave_pool).supply(
            WETH,
            amountWeth,
            msg.sender,
            0
        );
    }

    function withdrawWethfromAave(uint amountOut) external {
        aave_pool=getPool();
        IERC20(aETHWETH).approve(aave_pool,amountOut);
        IPool(aave_pool).withdraw(WETH,amountOut,msg.sender);

    }

    function getPool() public returns(address){
         aave_pool=IPoolAddressProvider(AAVE_POOL_ADD_PROVIDER).getPool();
        return aave_pool;
    }


    function getUserAccountData(address user) public returns(uint,uint,uint,uint,uint,uint){
       (uint256 totalCollateralBase,
      uint256 totalDebtBase,
      uint256 availableBorrowsBase,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor)= IPool(aave_pool).getUserAccountData(user);

    return (totalCollateralBase,totalDebtBase,availableBorrowsBase,currentLiquidationThreshold,ltv,healthFactor);

    }

    function getAllATokens(string memory _symbol) public returns(address){
        IProtocolDataProvider.TokenData[] memory response=IProtocolDataProvider(AAVE_DATA_PROVIDER).getAllATokens();
        for(uint i=0;i<response.length;i++){
            if(keccak256(abi.encodePacked(response[i].symbol)) == keccak256(abi.encodePacked(_symbol))){
                return response[i].token;
            }
        }
         // Revert if no token is found with the given symbol
    revert("Token with the specified symbol not found");
       
    }
    
    
    function getTokenBalances(address user) public returns(uint,uint){
        uint wethBalance=IWETH(WETH).balanceOf(user);
        uint usdcBalance=IERC20(USDC).balanceOf(user);
        // uint aEthUSDCBalance=IERC20(aEthUSDC).balanceOf(user);
        // uint aETHWETHBalance=IERC20(aEthUSDC).balanceOf(user);


        return (wethBalance,usdcBalance);
    }




    receive() external payable {}


}