
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Iminiaaveinterface.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract VaultAutomate is Ownable{

    address FeeReciver;
    address DAItoken;
    Iminiaaveinterface public AAvecontract;
    using SafeERC20 for IERC20;
    uint256 fees;

    uint256 public feevalue = 2;

    mapping (address => uint256) public Deposit;

    constructor(address _feereciver , address _aavecontractaddress , address Daitoken) Ownable(){

        require(_feereciver != address(0), "Invalid Adress"); 
        require(Daitoken != address(0) , "Invalid Daitoken address");   
        DAItoken = Daitoken;
        AAvecontract = Iminiaaveinterface(_aavecontractaddress);
        FeeReciver = _feereciver;

    }


    //only can accept DAI tokens only



    function depositamount(uint256 amount) external returns (bool){

        require(amount > 0 , "Amount should be more than Zero");

        require(IERC20(DAItoken).balanceOf(msg.sender) >= amount , "Insuffient amount");

        IERC20(DAItoken).safeTransferFrom(msg.sender , address(this) , amount);

        IERC20(DAItoken).approve(address(AAvecontract), amount);
        
        bool result = AAvecontract.lendtokens(DAItoken,amount);

        if(result){

            Deposit[msg.sender] += amount;
        }

        return true;

    }



    function withdrawamount() external returns (uint256 finalamount){

        require(Deposit[msg.sender] > 0 , "You should despoit first");

        uint256 amount = Deposit[msg.sender];

        uint256 totalamount = AAvecontract.withdrawlendtokens(amount);


        uint256 feecalculation;

        if(totalamount > 10000){  

             feecalculation = (totalamount * feevalue) / 100;
             IERC20(DAItoken).safeTransfer(FeeReciver, feecalculation);

        }


        finalamount = totalamount - feecalculation;

        Deposit[msg.sender] = 0;

        fees += feecalculation;

        IERC20(DAItoken).safeTransfer(msg.sender, finalamount);



        
    }



    function withdrawfees() external onlyOwner{

        require(fees > 0 , "Fees - 0");

        IERC20(DAItoken).safeTransfer(FeeReciver , fees);

        
    }


    function changefeereciver(address newFeereciver) external onlyOwner{
        require(newFeereciver != address(0) , "Invalid address");
        FeeReciver = newFeereciver;
    }


    function changefeevalue (uint256 newfee) external onlyOwner{
        require(newfee > 0 && newfee < 10 , "fee should be more than zero and less than 10");
        feevalue = newfee;
    }


    function getdepositamount() external view returns (uint256){

        return Deposit[msg.sender];
    }


    function GetlendingAmount() external view returns (uint256){

        return AAvecontract.lendingamount();
    }


}