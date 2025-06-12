
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Script.sol";
import {Daitoken} from "../src/Tokenontract/Daitoken.sol";
import {Ethtoken} from "../src/Tokenontract/Ethtoken.sol";
import {MiniAave} from "../src/MiniAaave.sol";
import {VaultAutomate} from "../src/VaultMain.sol";

contract VaultMainScript is Script {

    Daitoken public dai;
    Ethtoken public eth;
    MiniAave public miniAave;
    VaultAutomate public vault;


    function run() external {
        vm.startBroadcast();
        dai = new Daitoken(1000000);
        eth = new Ethtoken(1000000);
        miniAave = new MiniAave(address(eth), address(dai));
        vault = new VaultAutomate(
            0x1234567890123456789012345678901234567890, // Replace with actual fee receiver address
            address(miniAave),
            address(dai)
        );

        vm.stopBroadcast();        
    }
}


// forge script script/VaultMain.s.sol:VaultMainScript \
//   --rpc-url http://127.0.0.1:8545 \
//   --broadcast \
//   --private-key 0x<ANVIL_PRIVATE_KEY>
