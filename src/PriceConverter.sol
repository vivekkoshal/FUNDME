// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 


library PriceConverter{
     function getPrice(AggregatorV3Interface pricefeed)internal view returns(uint256){
       //  AggregatorV3Interface pricefeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);   //we gave it in constructor
       
        (/*uint80 roundId*/, int256 price, /*uint256 startedAt*/, /*uint256 updatedAt*/, /*uint80 answeredInRound*/) = pricefeed.latestRoundData(); // this function returns many thing but we only need price
         return uint256(price* 1e10); 
        }

    function getversin()  public view returns(uint256){
        AggregatorV3Interface myversion = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return myversion.version();   
    }

    
    function getConversionRate(uint256 ethAmount , AggregatorV3Interface pricefeed) internal  view returns (uint256){
        uint256 ethPrice  = getPrice(pricefeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;
        return ethAmountInUsd;
    }

}


