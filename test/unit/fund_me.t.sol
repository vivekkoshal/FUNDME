//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import{Test, console} from "forge-std/Test.sol";
import{fund_me} from "../../src/fund_me.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract fundmeTest is Test{   //we implemented Test to use the function deployed in it
    
    fund_me fundme;                      //declaring the object


      address USER = makeAddr("user") ; //this is a cheat code which will make a random addres(a fake user) by which we will make tansaction to make thigs easy
      uint256 constant SENT_VALUE = 100000000000000000 ; //0.1 eth = 1000000000000000000 (17 zeros)
      uint256 constant STARTING_BALANCE = 10000000000000000000; //(19zeros) = 10ETH     //starting balace of the user given by ceat code vm.deal(USER,STARTING_BALANCE) in setup function
      uint256 constant GAS_PRICE = 1;

    function setUp() external{                       //makes object 
    //fundme = new fund_me(0x694AA1769357215DE4FAC081bf1f309aDC325306);   //now we will deploy only once in script
    DeployFundMe deployfundme = new DeployFundMe();
    fundme = deployfundme.run();
    vm.deal(USER,STARTING_BALANCE);    //this gives some intial balance to the user that he can use
   
    }
    function testDemo() public{                        //test on the object created by function
     //    console.log(number);                        //used to print things in terminal 
     //    console.log("hello blockchain");            //used for debuging
     // assertEq(number,2);                            //used to check A==B or not declared in Test
    }

    function testMinimumDollarisFive() public view {
          assertEq(fundme.MINIMUM_USD() , 5e18);                            
    }

    function testOwneriMsgSender() public view {
        console.log(fundme.getOwner());
        console.log(msg.sender);     //us->fund_me.t.sol -> fundme
         // assertEq(fundme.i_owner() , address(this)); //this will be correct if we setup fundme here 
         assertEq(fundme.getOwner(), msg.sender); //this is correct if if deploy once in the script and use it here
    }
    function testgetVersyion() public view {
          console.log(fundme.getversin());
          uint256 version = fundme.getversin();
          assertEq(version , 4);

    }

    //now test each function top to bottom
    function testFundmeFailWithoutEnoughEth() public {
          vm.expectRevert(); //type of ceat code -> the next line should revert     work as Assert(this transaction fail / revert)
          fundme.fund();  //here the value passsed is zero which is less that minimum usd ($5)
    }


  
    function testFundUpdatesFundedDataStructure() public {      //this function check the balance of our account incrased or not

      vm.prank(USER); //this is a cheat code -> the next transaction will be sent by USER
      

        //  fundme.fund({value:1e17});   //here we sent 0.1ETH >> 5$    //this is wrong syntex to pass value
      fundme.fund{value : SENT_VALUE}();        //here instead of magic number we defined at the top
      uint256 amountFunded = fundme.getAddressToAmountFunded(USER);   //address(this)) instead of USER will be  correct if  we not used prank function and used fundme setup here using mock
      assertEq(amountFunded , SENT_VALUE);
    }

      function testADDsFunderToArrayOfFunders() public {
            vm.prank(USER);
            fundme.fund{value : SENT_VALUE}();

            address funder = fundme.getFunders(0);

            assertEq(funder, USER);
      }


      modifier funded(){                      //by this we donot need to write these two lines in functions again and again
       vm.prank(USER);
       fundme.fund{value : SENT_VALUE}();
       _;
      }

      function testOnlyOwnerCanWithdraw ()  public funded {    //as we used modifier funder we donot need to write the bellow two lines
      //    vm.prank(USER);
      //    fundme.fund{value : SENT_VALUE}();

         vm.expectRevert();   //this says next line must revert but it ignors vm cheatcodes (prank)
         vm.prank(USER);
         fundme.withdraw();            //this will revert as USER is (msg.sender in function) and i_owner is (address(this)as it is deployed in mock enviornment) 
      }

      function testWithdrawIsSuccessfullByOwner()  public funded { 
     //Usally Tests are Written As 1-> Arrange ; 2-> Act ; 3-> Assert;
      
      //Arrange    (we will first check the initial owner ballance )
      uint256 initialOwnerBalance = fundme.getOwner().balance;    //.blance() is global word same as sender , valve and gives balance of that address    
      uint256 initialFundmeBalance = address(fundme).balance;

      //Act    (here we will actually withdraw)

  //    uint256 gasStart = gasleft();  //gasleft is a solidity which gives how much gas is left in our transaction
  //    vm.txGasPrice(GAS_PRICE);    //anavil by default gas price is zero we can set a gas price using this 

      vm.prank(fundme.getOwner()) ; //this ensures that owner is making transaction
      fundme.withdraw();        //this will make fundeme balance 0                //should we spent gas?

      //    uint256 gasUsed = gasStart - gasleft();  // Calculate the gas used
      //    uint256 gasCost = gasUsed * tx.gasprice;      //this will give the gas used in this transaction      //tx.price is also soolidity builtin function which tells gas price
      //   console.log(gasUsed); 
      //Assert   (this we check the final balane matches or not)
      uint256 endingOwnerBalance = fundme.getOwner().balance;
      uint256 endingFundmeBalance = address(fundme).balance;
      assertEq(endingOwnerBalance , initialOwnerBalance + initialFundmeBalance);
      assertEq(endingFundmeBalance , 0);
     
      }

      function testWithdrawFromMultipleFunders()  public funded {
      
      uint160 numberofFunders = 10;     //we can cast uint160 to address but not uint256(as uint160 and address has same bites)
      uint160 startingFunderIndex = 1 ; 
      
      for(uint160 i = startingFunderIndex ; i<numberofFunders ; i++){
            //creating address and assigning them initial values(SEND_VALUE = 0.1 eth)
            hoax(address(i) , SENT_VALUE);         //address(i) as i is uint160 will be converted to a address and hoax does both works(vm.prank , vm.deal) simuntaniously

            fundme.fund{value: SENT_VALUE}();     //this will give 0.9 eth to fund me + 0.1 eth is given by the modifier defined in function 

      }

      uint256 initialOwnerBalance = fundme.getOwner().balance;
      uint256 initialFundmeBalance = address(fundme).balance;

      vm.startPrank(fundme.getOwner());   //start and stop prank is just same as start broadcast prank will be in that region  only
      fundme.withdraw();
      vm.stopPrank();

      //Assert
      assertEq(address(fundme).balance , 0);
      assertEq(initialOwnerBalance + initialFundmeBalance , fundme.getOwner().balance);
      
      }

      
      function testCheapWithdrawFromMultipleFunders()  public funded {
      
      uint160 numberofFunders = 10;     //we can cast uint160 to address but not uint256(as uint160 and address has same bites)
      uint160 startingFunderIndex = 1 ; 
      
      for(uint160 i = startingFunderIndex ; i<numberofFunders ; i++){
            //creating address and assigning them initial values(SEND_VALUE = 0.1 eth)
            hoax(address(i) , SENT_VALUE);         //address(i) as i is uint160 will be converted to a address and hoax does both works(vm.prank , vm.deal) simuntaniously

            fundme.fund{value: SENT_VALUE}();     //this will give 0.9 eth to fund me + 0.1 eth is given by the modifier defined in function 

      }

      uint256 initialOwnerBalance = fundme.getOwner().balance;
      uint256 initialFundmeBalance = address(fundme).balance;

      vm.startPrank(fundme.getOwner());   //start and stop prank is just same as start broadcast prank will be in that region  only
      fundme.CheapWithdraw();
      vm.stopPrank();

      //Assert
      assertEq(address(fundme).balance , 0);
      assertEq(initialOwnerBalance + initialFundmeBalance , fundme.getOwner().balance);
      
      }


}