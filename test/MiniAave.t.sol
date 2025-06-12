// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {MockDaitoken} from "./Moctokencontract/Mockdai.t.sol";
import {MockEthtoken} from "./Moctokencontract/Mocketh.t.sol";
import {MiniAave} from "../src/MiniAaave.sol";
import {VaultAutomate} from "../src/VaultMain.sol";



contract Miniaavetest is Test {


    MockDaitoken public dai;
    MockEthtoken public eth;
    MiniAave public miniAave;
    VaultAutomate public vault;
    address public tokenowner = makeAddr("tokenowner");
    address public owner = makeAddr("owner");
    address public vaultowner = makeAddr("vaultowner");
    address public feeReciver = makeAddr("feeReciver");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");
    address public user4 = makeAddr("user4");


    function setUp() public {

        vm.startPrank(tokenowner);
        dai = new MockDaitoken(1000000);
        eth = new MockEthtoken(1000000);
        vm.stopPrank();

        vm.prank(owner);
        miniAave = new MiniAave(address(eth) , address(dai));


        vm.prank(vaultowner);
        vault = new VaultAutomate(feeReciver, address(miniAave), address(dai));


        vm.startPrank(tokenowner);
        dai.mint(address(miniAave), 100000);
        dai.mint(user1, 10000);
        dai.mint(user2, 1000);
        dai.mint(user3, 1000);
        dai.mint(user4, 100);

        eth.mint(user1, 1000);
        eth.mint(user2, 1000);
        eth.mint(user3, 1000);
        eth.mint(user4, 100);

        vm.stopPrank();

        
        assert(dai.balanceOf(address(miniAave)) == 100000);
        assert(dai.balanceOf(user1) == 10000);
        assert(dai.balanceOf(user2) == 1000);
        assert(dai.balanceOf(user3) == 1000);

    }


    function testlendtoken() external {

        vm.startPrank(user1);
        dai.approve(address(miniAave), 1000);
        console.log("Balance of user1 before lending", dai.balanceOf(user1));
        bool result = miniAave.lendtokens(address(dai), 1000);
        vm.stopPrank();
        assert(result == true);
        assert(miniAave.lendingamounteachperson(user1) == 1000);
        assert(dai.balanceOf(address(miniAave)) == 101000);
        assert(dai.balanceOf(user1) == 9000);

    }

    function testlendtokenerror1() external {

        vm.prank(user1);
        vm.expectRevert("the token can't be landing only DAI token can lend to earn passive income");
        miniAave.lendtokens(address(eth), 1000);     
    }

    function testlendtokenerror2() external {

        vm.prank(user4);
        vm.expectRevert("Insuffient amount");
        miniAave.lendtokens(address(dai), 1000000);     
    }

    
    function testlendtokenerror3() external {

        vm.prank(user1);
        vm.expectRevert("amount should be more than zero");
        miniAave.lendtokens(address(dai), 0);     
    }

    function testborrowtoken() external {

        vm.startPrank(user1);
        eth.approve(address(miniAave), 10);
        console.log(eth.balanceOf(user1));
        bool result = miniAave.borrowtokens(address(eth), address(dai), 10, 40);
        vm.stopPrank();
        assert(result == true);
        assert(dai.balanceOf(user1) == 10040);
        assert(eth.balanceOf(address(miniAave)) == 10);
        assert(miniAave.Colletralamounteachperson(user1) == 10);
        assert(miniAave.borrowedamounteachperson(user1) == 40);
        
    }


    function testborrowtokenerror1() external {

        vm.prank(user1);
        vm.expectRevert("Invalid token address");
        miniAave.borrowtokens(address(dai), address(eth), 10, 40);     

    }

    function testborrowtokenerror2() external {

        vm.prank(user1);
        vm.expectRevert("Insuffient amount");
        miniAave.borrowtokens(address(eth), address(dai), 10, 400000);     

    }

    function testborrowtokenerror3() external {

        vm.prank(user1);
        vm.expectRevert("Insuffient collertal amount");
        miniAave.borrowtokens(address(eth), address(dai), 100000, 40000);     

    }

    function testborrowtokenfalse() external {

        vm.prank(user1);
        bool result = miniAave.borrowtokens(address(eth), address(dai), 10, 100);
        assert(result == false);

    }


    function testrepayloan() external {
        
        vm.warp(block.timestamp);
        vm.startPrank(user1);
        eth.approve(address(miniAave), 10);
        console.log(eth.balanceOf(user1));
        miniAave.borrowtokens(address(eth), address(dai), 10, 40);
        vm.stopPrank();


        vm.warp(block.timestamp + 30 days);
        vm.startPrank(user1);
        uint256 interest = miniAave.calculateInterest(user1, block.timestamp, 40, false);
        uint256 totalAmountToPay = 40 + interest;
        dai.approve(address(miniAave), totalAmountToPay);
        miniAave.repayloan( address(dai), 40);


        assert(eth.balanceOf(address(miniAave)) == 0);
        assert(eth.balanceOf(user1) == 1000);
        assert(miniAave.Colletralamounteachperson(user1) == 0);
        assert(miniAave.borrowedamounteachperson(user1) == 0);

    }


    function testrepayloan1() external {
        
        vm.warp(block.timestamp);
        vm.startPrank(user1);
        eth.approve(address(miniAave), 10);
        console.log(eth.balanceOf(user1));
        miniAave.borrowtokens(address(eth), address(dai), 10, 40);
        vm.stopPrank();


        vm.warp(block.timestamp + 30 days);
        vm.startPrank(user1);
        uint256 interest = miniAave.calculateInterest(user1, block.timestamp, 30, false);
        uint256 totalAmountToPay = 30 + interest;
        dai.approve(address(miniAave), totalAmountToPay);
        miniAave.repayloan( address(dai), 30);

        assert(eth.balanceOf(address(miniAave)) == 10);
        assert(eth.balanceOf(user1) == 990);
        assert(miniAave.Colletralamounteachperson(user1) == 10);
        assert(miniAave.borrowedamounteachperson(user1) == 10);

    }



    function testwithdrawlendtoken() external{
        
        vm.warp(block.timestamp);
        vm.startPrank(user1);
        dai.approve(address(miniAave), 1000);
        console.log("Balance of user1 before lending", dai.balanceOf(user1));
        miniAave.lendtokens(address(dai), 1000);
        vm.stopPrank();


        vm.warp(block.timestamp + 30 days);
        vm.startPrank(user1);
        uint256 interest = miniAave.calculateInterest(user1, block.timestamp, 1000, true);
        miniAave.withdrawlendtokens(1000);
        vm.stopPrank();

        assert(dai.balanceOf(user1) == 10000 + interest);
        assert(miniAave.lendingamounteachperson(user1) == 0);

    }


    function testupdatepriceoracle() external {

        vm.prank(owner);
        miniAave.updateprice(address(eth) , 2000);
        assert(miniAave.getprice(address(eth)) == 2000);

    }


    function testupdatepriceoracleerror() external {

        vm.prank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        miniAave.updateprice(address(eth) , 2000);


    }



    function testchangerate() external {

        vm.prank(owner);
        miniAave.changeRate(10);
        assert(miniAave.Intrest_Rate() == 10);

    }




    //Vaultmaincontract test cases


    function testdeposit() external {

        vm.startPrank(user1);
        dai.approve(address(vault), 1000);
        bool result = vault.depositamount(1000);
        vm.stopPrank();
        assert(result == true);
        assert(vault.Deposit(user1) == 1000);
        assert(dai.balanceOf(user1) == 9000);
    }

    function testdepositerror1() external {

        vm.prank(user1);
        vm.expectRevert("Amount should be more than Zero");
        vault.depositamount(0);     
    }

    function testdepositerror2() external {

        vm.prank(user1);
        vm.expectRevert("Insuffient amount");
        vault.depositamount(1000000);     

    }

    function testwithdraw() external {

        vm.startPrank(user1);
        dai.approve(address(vault), 1000);
        vault.depositamount(1000);
        vm.stopPrank();

        vm.warp(block.timestamp + 30 days);
        vm.prank(user1);
        vault.withdrawamount();
        assert(vault.Deposit(user1) == 0);    
        
    }
        
    
}