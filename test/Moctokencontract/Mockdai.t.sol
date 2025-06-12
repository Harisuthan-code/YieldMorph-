// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockDaitoken is ERC20, Ownable {

    constructor(uint256 initialSupply) ERC20("Daimocktoken", "Dmock") Ownable() {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /// @notice Owner can mint new tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Owner can burn tokens from any address
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
