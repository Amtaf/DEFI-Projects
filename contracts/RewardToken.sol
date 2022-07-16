//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("MY RewardToken","MRT"){
        _mint(msg.sender, 1000000*10**18);
        
    }
}