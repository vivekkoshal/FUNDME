///SPDX-License-Identifier: MIT
//1-> we will deploy mocks when we are on local anvil chain
//keep track of contracts address across differnt chains Eg->//sepolia ETH/USD //Mainnet ETH/USD


//(after this we no more need to pass rpc url to test cases)
pragma solidity ^0.8.18;
import{Script} from "forge-std/Script.sol";
import{MockV3Aggregator} from "../test/mocks/MOCKV3Aggregator.sol";

contract HelperConfig is Script{
//if we are on a local anvil chain we will deploy mocks
//otherwise we will grab exisiting adress from live network

//we will create  new type of network config to store everthing in one
struct NetworkConfig{
    address priceFeed;
    //can also add other things if we want
}

NetworkConfig public activeNetworkConfig;

constructor(){
    if ( block.chainid == 11155111){    //block.chainid is global variable same as msg.value etc it give the current chain id //on chainlist.orf we get all the chain id
        activeNetworkConfig = getSepoliaEthConfig();
    }
    else if(block.chainid == 1){
        activeNetworkConfig = getMainNetEthConfig();
    }
    else{
       activeNetworkConfig = getOrCreateAnvailEthConfig();
    }
}

//1->grab exisiting adress from live network

function getSepoliaEthConfig() public pure returns(NetworkConfig memory){    //memory is used as its a special type
    //price feed address
    NetworkConfig memory SepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    return SepoliaConfig;

}
function getMainNetEthConfig() public pure returns(NetworkConfig memory){
 //price feed address
    NetworkConfig memory MainNetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    return MainNetConfig;

}

//2->if we are on a local anvil chain we will deploy mocks
function getOrCreateAnvailEthConfig() public  returns(NetworkConfig memory){
    if( activeNetworkConfig.priceFeed != address(0)){       //tis line says that if we have set pricefeed as its not eyal to 0 return that
        return activeNetworkConfig;
 }

    //price feed address
    //1->deploy the mocks(dummry contract)
    //2->return mock address
    
    vm.startBroadcast();            //to deploy in the anvil chain we are working with
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);     //we said 2000 is satarting price   //8 repesents the number of decimals in eth usd
    vm.stopBroadcast();

    //we have deployed the mock now return the address
    NetworkConfig memory AnvailConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    return AnvailConfig;

}     
}