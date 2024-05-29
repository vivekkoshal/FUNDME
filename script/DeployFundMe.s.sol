//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import{Script} from"forge-std/Script.sol";
import {fund_me} from "../src/fund_me.sol";
import{HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {                      //is script is used to use key works like vm.startBroadcast() and vm.stopBroadcast()

    function run() external returns(fund_me){           //return is done for setup function in test
        
        HelperConfig helperConfig = new HelperConfig();   //its before broadcast hence it will not send gas when deployed on real chain
       (address ethUsedPriceFeed) = helperConfig.activeNetworkConfig();
        //real transaction(tx) startes after broadcast
        vm.startBroadcast();
     //   fund_me fundme = new fund_me(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //USEing MOCK
        fund_me fundme = new fund_me(ethUsedPriceFeed);
         vm.stopBroadcast();

        return fundme;              //no need to setup twice
    }


}