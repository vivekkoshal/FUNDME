//SPDX-License_Identifier: MIT

pragma solidity ^0.8.18;


//we will write two scripts //fund and //withdraw
import{fund_me} from "../src/fund_me.sol";
import{Script , console} from "forge-std/Script.sol";
import{DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol"; //this is will provide the most recently deployed function

contract Fundfundme is Script{

  //  uint256 SENT_VALUE = 1000000000000000000; //1 eth

    function fundfundme(address mostRecentlyDeployed) public{
        vm.startBroadcast();
     
        fund_me(payable(mostRecentlyDeployed)).fund{value : 1e18}();
         vm.stopBroadcast();

    //   console.log("Funded fundme with %s" , SENT_VALUE);
    }

    function run() external{
        address mostRecentlyDeployed  = DevOpsTools.get_most_recent_deployment("fund_me" , block.chainid);
        
        fundfundme( mostRecentlyDeployed);
       
    }
}




contract Withdrawfundme is Script{
    function withdrawfundme(address mostRecentlyDeployed) public{
        vm.startBroadcast();
        fund_me(payable(mostRecentlyDeployed)).withdraw();
 vm.stopBroadcast();

    }

    function run() external{
        address mostRecentlyDeployed  = DevOpsTools.get_most_recent_deployment("fund_me" , block.chainid);
        
        withdrawfundme(mostRecentlyDeployed);
        
    }
}