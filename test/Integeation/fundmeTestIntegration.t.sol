//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import{Test, console} from "forge-std/Test.sol";
import{fund_me} from "../../src/fund_me.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import{Fundfundme , Withdrawfundme} from "../../script/Interaction.s.sol";

contract InteractionsTest is Test{
       fund_me fundme;


      address USER = makeAddr("user") ; //this is a cheat code which will make a random addres(a fake user) by which we will make tansaction to make thigs easy
      uint256 constant SENT_VALUE = 10000000000000000000 ; //10 eth = 1000000000000000000 (17 zeros)
      uint256 constant STARTING_BALANCE = 100000000000000000000; //(19zeros) = 10ETH     //starting balace of the user given by ceat code vm.deal(USER,STARTING_BALANCE) in setup function


    function setUp() external{
    DeployFundMe deploy = new DeployFundMe();
    fundme = deploy.run(); 
    vm.deal(USER,STARTING_BALANCE);  
    }

    function testUserCanFundInteractions() public{
        Fundfundme fundfundme = new Fundfundme();
        fundfundme.fundfundme(address(fundme));

        Withdrawfundme withdrawfundme = new Withdrawfundme();
        withdrawfundme.withdrawfundme(address(fundme));

          assertEq(address(fundme).balance , 0);
    }

}