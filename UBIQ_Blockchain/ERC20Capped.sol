// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;

import "./SafeMath.sol";
//import "./ERC20.sol";



/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
contract ERC20Capped {
    using SafeMath for uint256;

    uint256 private _cap;

    /**
    * @dev Sets the value of the `cap`. This value is immutable, it can only be
    * set once during construction.
    */
    constructor (uint8 dec_, uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_ * (10**dec_);
    }


    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Set the cap on the token's total supply.
     */
    function setCap(uint256 amount) public virtual returns (bool) {
        require(amount > 0, "ERC20Capped: cap is 0");
        _cap = amount;
        
        return true;
    }
}
