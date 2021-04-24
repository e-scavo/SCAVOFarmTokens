// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;

import "./SafeMath.sol";
import "./Context.sol";
import "./ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to mint tokens on a recovery scenario
 */
abstract contract ERC20Mintable is Context, ERC20 {
    using SafeMath for uint256;

    /**
     * @dev Mint `amount` tokens from the caller.
     *
     * See {ERC20-_mint}.
     */
    function mint(uint256 amount) public virtual returns(bool){
        _mint(_msgSender(), amount);
        return true;
    }
}
