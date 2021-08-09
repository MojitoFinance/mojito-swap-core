pragma solidity =0.5.16;

import '../MojitoERC20.sol';

contract ERC20 is MojitoERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
