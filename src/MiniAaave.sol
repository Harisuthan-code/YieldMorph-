
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Priceoracle} from "./Priceoracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MiniAave is ReentrancyGuard  , Ownable {
     
    using SafeERC20 for IERC20;

    Priceoracle public priceoracle;

    address Collertraltoken;
    address Borrowtoken;
    address prooftoken;


    mapping (address => uint256 ) public lendingamounteachperson;
    mapping (address => uint256) public eachpersonintrest;
    mapping (address => uint256) public borrowedamounteachperson;
    mapping (address => uint256) public Colletralamounteachperson;
    mapping (address => uint256) public lendertime;
    mapping (address => uint256) public borrowertime;

    uint256 public Intrest_Rate = 5;

    constructor(address colletral , address borrow) Ownable(){
        
        Collertraltoken = colletral;
        Borrowtoken = borrow;    
        priceoracle = new Priceoracle(colletral , borrow , 1000 , 200);  

    }


    function lendtokens(address lendtoken , uint256 lending_amount) external nonReentrant returns (bool){

        require(lendtoken == Borrowtoken , "the token can't be landing only DAI token can lend to earn passive income");
        require(IERC20(lendtoken).balanceOf(msg.sender) >= lending_amount , "Insuffient amount");
        require(lending_amount > 0 , "amount should be more than zero");
        IERC20(lendtoken).safeTransferFrom(msg.sender , address(this) , lending_amount);
        lendingamounteachperson[msg.sender] += lending_amount;
        lendertime[msg.sender] = block.timestamp;
        return true;

    }

    function borrowtokens(address collateraltoken , address borrowtoken , uint collertalamount , uint256 borrowamount) external nonReentrant  returns (bool){

        require(Borrowtoken == Borrowtoken , "Invalid token address");
        require(Collertraltoken == collateraltoken , "Invalid token address");
        require(borrowamount <= IERC20(Borrowtoken).balanceOf(address(this)) , "Insuffient amount");
        require(collertalamount <= IERC20(collateraltoken).balanceOf(msg.sender) , "Insuffient collertal amount");
        require(collertalamount > 0 && borrowamount > 0 , "Invalid amount");



        uint256 collertaltokencurrentprice = priceoracle.getprice(collateraltoken);    //1000
        uint256 borrowtokencurrentprice = priceoracle.getprice(borrowtoken);           //200


        uint256 totalamountofcollertal = collertaltokencurrentprice * collertalamount;   //1000 * 10 = 10000
        uint256 max_amount_borrow = totalamountofcollertal / borrowtokencurrentprice;   //10000 / 200 = 50

        
        if(max_amount_borrow >= borrowamount){

            IERC20(borrowtoken).safeTransfer(msg.sender , borrowamount);
            IERC20(collateraltoken).safeTransferFrom(msg.sender ,  address(this), collertalamount);
            borrowedamounteachperson[msg.sender] += borrowamount;
            Colletralamounteachperson[msg.sender] += collertalamount;
            borrowertime[msg.sender] = block.timestamp;
            return true;

        }

        else{

            return false;
        }



    }



    function repayloan(address Borrowtokenaddress , uint256 amounttopay) external nonReentrant returns (bool){

        require(borrowedamounteachperson[msg.sender] > 0 , "Not in borrower list");
        require(amounttopay > 0 , "it should be more than 0");
        require(Borrowtoken == Borrowtokenaddress , "invalid borrow token address");
        require(borrowedamounteachperson[msg.sender] >= amounttopay , "You can't pay more than you borrowed");


        uint256 borrowedamount = borrowedamounteachperson[msg.sender];
        uint256 calculateintrestamount = calculateInterest(msg.sender , block.timestamp , amounttopay , false);

        if(borrowedamount == amounttopay){
            
            IERC20(Borrowtokenaddress).safeTransferFrom(msg.sender ,  address(this), amounttopay);
            IERC20(Collertraltoken).safeTransfer(msg.sender ,  Colletralamounteachperson[msg.sender]);
            borrowedamounteachperson[msg.sender] = 0;
            Colletralamounteachperson[msg.sender] = 0;
            borrowertime[msg.sender] = 0;        

        }

        else{

            IERC20(Borrowtokenaddress).safeTransferFrom(msg.sender ,  address(this), amounttopay);
            borrowertime[msg.sender] = block.timestamp;
            borrowedamounteachperson[msg.sender] -= amounttopay;

        }


        IERC20(Borrowtokenaddress).safeTransferFrom(msg.sender ,  address(this), calculateintrestamount);
        eachpersonintrest[msg.sender] += calculateintrestamount;

        return true;

    }


 

    function calculateInterest(address sender, uint256 endtime, uint256 amount , bool iscallerlenderorborrower) public view returns (uint256 interestAmount) {
    
    uint256 starttime;

    if(iscallerlenderorborrower){

         starttime = lendertime[sender];
    }

    else{

         starttime = borrowertime[sender];

    }

    require(endtime >= starttime, "Pay time must be after borrowed time");

    uint256 timeElapsed = endtime - starttime; 
    uint256 secondsInMonth = 30 * 24 * 60 * 60; 

    if (timeElapsed < secondsInMonth) {
        return 0; 
    }

    uint256 fullMonths = timeElapsed / secondsInMonth;

    interestAmount = (amount * Intrest_Rate * fullMonths) / 100; 

    return interestAmount;

    }



    function withdrawlendtokens(uint256 amount) external nonReentrant  returns (uint256 totalamount){

    require(lendingamounteachperson[msg.sender] > 0 , "Not in Lender list");
    require(lendingamounteachperson[msg.sender] >= amount , "You can't withdraw more than you lent");
    uint256 calculateintrest_amount = calculateInterest(msg.sender , block.timestamp , amount , true);
    require(amount + calculateintrest_amount <= IERC20(Borrowtoken).balanceOf(address(this)) , "Not enough liquidity in the pool. Please try again later or wait for borrowers to repay");


    if(calculateintrest_amount == 0){
        
        totalamount = amount;
        IERC20(Borrowtoken).safeTransfer(msg.sender  , amount);

    }


    else{

        totalamount = calculateintrest_amount + amount;
        IERC20(Borrowtoken).safeTransfer(msg.sender  , totalamount);

    }


    lendingamounteachperson[msg.sender] -= amount;
    lendertime[msg.sender] = block.timestamp;




    }




    function updateprice(address token , uint256 value) external onlyOwner returns (bool){
        require(token == Borrowtoken || token == Collertraltoken , "invalid token addeess");
        uint256 pricecollteraltoken = priceoracle.getprice(Collertraltoken);
        uint256 priceborrowedtoken = priceoracle.getprice(Borrowtoken);

        if(token == Borrowtoken && value < pricecollteraltoken ){

            priceoracle.updateprice(token, value); 

        }

        else if (token == Collertraltoken && value > priceborrowedtoken ){

            priceoracle.updateprice(token, value); 

        }

        
        return true;

    }


    function getprice(address token) external view returns (uint256){

        require(token == Borrowtoken || token == Collertraltoken , "invalid token address");
        return priceoracle.getprice(token);

    }


    function getloanamount() external view returns (uint256){
        
        require(borrowedamounteachperson[msg.sender] > 0 , "Not in borrower list");
        return borrowedamounteachperson[msg.sender];
    }

    function getcollertalamount() external view returns (uint256){
        
        return  Colletralamounteachperson[msg.sender];
    }


    function getPaidIntrest() external view returns (uint256){

        return eachpersonintrest[msg.sender];
    }

    function lendingamount() external view returns(uint256){

        require(lendingamounteachperson[msg.sender] > 0 , "Not in Lender list");

        return lendingamounteachperson[msg.sender];

    }

    function changeRate(uint256 Intrestrate) external onlyOwner{

        require(Intrestrate > 0 , "Invalid intrest Rate");
        Intrest_Rate = Intrestrate;

    }


}


