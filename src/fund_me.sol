// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 


error NotOwner();

//initally the gas usage was->752,040 (using some tricks we will make it less)
//finally gas used ->720,865
contract fund_me{
    using PriceConverter for uint256; //to attach the functions in PriceConverter library to uint256 (all uint256 has acces to all functions in PriceConverter Library)
 
   uint256 public constant  MINIMUM_USD = 5 * 1e18 ; //(minimum amount we want the user to pay) (solidity does not has zeros so we multipy it bu 1e18 explained in getconversion rate function)    //constant is used to make it more gas efficient(convention all letter capital)
    //21,415 gas- constant         gas used in call function        
    //23,515 gas -- non constant
    //21,415* 141000000000 =$9.058   
    //23,515*141000000000 = $9.946     //almost 1 dollar differnce in just call function


    address[] private s_funders;   //we want to keep an array of addresses of the senders       //refactoring-> storage veriable usually satrts with s_
    //we have defined getter(view/pure function) at the end to get these value (private functions are more gas efficient)
    mapping (address sender => uint256 value) private s_addresstoAmountFunded;  //sender and value are just added to make it more clear(naming types)


    
    function fund() public payable{  

       require(msg.value.getConversionRate(s_priceFeedadr) >= MINIMUM_USD  , "Not enough ETH");  //here msg.value is passes as input in getConversionRate()  [it will always be the first parameter to be passed if there are more than one parameter they will be put in ()]
       s_funders.push(msg.sender); // msg.sender gives the adress of the sender 
       s_addresstoAmountFunded[msg.sender] = s_addresstoAmountFunded[msg.sender]+msg.value ; //we also want how much money is send my which sender (+ is done if a sender twice his value will be incrented)
    }

    address private immutable i_owner;
    //I want only myself to withdraw as owner
    AggregatorV3Interface private s_priceFeedadr;    //I also want that i can run test for any test net price feed i want by passing it in the constructor

    constructor(address pricefeed){  
        i_owner = msg.sender;      //owner will be the first one to deploy this[First transaction] and hence owner will take the owners address 
        s_priceFeedadr = AggregatorV3Interface(pricefeed);   
     }
   

    function withdraw() public onlyOwner{

        for(uint256 funderIndex = 0 ; funderIndex< s_funders.length ; funderIndex++ ){
            address funder = s_funders[funderIndex];
            s_addresstoAmountFunded[funder] =0;
        }

        //resetig the s_funders array
        s_funders = new address[](0);

        (bool callSuccess , /*bytes memory datreturn*/ )=payable(msg.sender).call{value: address(this).balance}("")  ;//call(here we put any function information we want) 
        //call function returns two value bool[sucess or not] and bytes(arrays , type(memory) must be spacified)[any information ] 
         require(callSuccess , "call failed");

        
    }
    
    //we make a more efficient withdraw function
    function CheapWithdraw() public onlyOwner{
        uint256 funderslength = s_funders.length;  //this way we only read the storage variable only once 

       for(uint256 funderIndex = 0 ; funderIndex < funderslength ; funderIndex++ ){
            address funder = s_funders[funderIndex];
            s_addresstoAmountFunded[funder] =0;
        }

        s_funders = new address[](0);

        (bool callSuccess , /*bytes memory datreturn*/ )=payable(msg.sender).call{value: address(this).balance}("")  ;//call(here we put any function information we want) 
        //call function returns two value bool[sucess or not] and bytes(arrays , type(memory) must be spacified)[any information ] 
         require(callSuccess , "call failed");




    }

    modifier onlyOwner(){
       if(msg.sender != i_owner){ revert NotOwner() ; }
        _;     //this is for the rest of the function
    }


    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getversin()  public view returns(uint256){
       // AggregatorV3Interface myversion = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //return myversion.version();   
        return s_priceFeedadr.version(); // as we implimented it in the constructor
    }

    //view /pure functions(Getters)
    function getAddressToAmountFunded(address funderadr) public view returns(uint256){
        return s_addresstoAmountFunded[funderadr];
    }

    function getFunders(uint256 index ) public view returns(address){
        return s_funders[index];
    }

    function getOwner() public view returns(address){
        return i_owner;
    }

}