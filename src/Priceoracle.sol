

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";


contract Priceoracle is Ownable{


    mapping (address => uint) public Tokenprice;


    constructor(address ethtoken , address daitoken , uint256 ethtokenprice , uint256 daitokenprice) Ownable(){
        require(ethtokenprice > 0 && daitokenprice > 0 , "require price should be greter than 0");
        Tokenprice[ethtoken] = ethtokenprice;
        Tokenprice[daitoken] = daitokenprice;
    }


    function updateprice(address token , uint256 value) external onlyOwner{
        require(value > 0 , "value should be more than zero");
        require(Tokenprice[token] > 0 , "invalid token address");
        Tokenprice[token] = value;
    }

    function getprice(address token) external view returns(uint256){

        require(Tokenprice[token] > 0 , "invalid token address");
        return Tokenprice[token];

    }





}