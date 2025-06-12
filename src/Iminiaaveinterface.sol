// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface Iminiaaveinterface {

    function lendtokens(address lendtoken , uint256 lending_amount) external returns (bool);
    function withdrawlendtokens(uint256 amount) external returns (uint256 totalamount);
    function lendingamount() external view returns(uint256);
    
}