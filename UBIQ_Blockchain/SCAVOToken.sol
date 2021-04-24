// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
//import "./Context.sol";
//import "./IERC20.sol";
import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Mintable.sol";
import "./ERC20Capped.sol";
import "./ERC20Pausable.sol";
import "./ERC20Snapshot.sol";
//import "./SafeERC20.sol";
import "./Ownable.sol";
import "./SCAVOCompany.sol";
import "./SCAVOTokenAdvanced.sol";
import "./SCAVOTokenBallot.sol";

//, SCAVOCompany
contract SCAVOToken is ERC20, Ownable, Pausable, ERC20Burnable, ERC20Capped, ERC20Mintable, ERC20Snapshot, SCAVOTokenAdvanced, SCAVOTokenBallot, SCAVOCompany
{
    using SafeMath for uint256;
    
    string  private _version;
    uint256 private _createdOn;

    constructor(string memory pName, string memory pSymbol, uint8 pDecimals, uint256 pTotalSupply, uint256 pInitialMintedSupply) 
    ERC20(pName, pSymbol, pDecimals, pTotalSupply, pInitialMintedSupply)
    Ownable()
    Pausable()
    ERC20Capped(pDecimals, pTotalSupply)
    {
        _version = "1.7";
        _createdOn = block.timestamp;
        _updateHoldersList(_msgSender());
    }
    /**
     * @dev Returns the version of the token.
     */
    function version() public view returns (string memory) {
        return _version;
    }

    /**
     * @dev Returns the createdOn of the token.
     */
    function createdOn() public view returns (uint256) {
        return _createdOn;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * - contract must not be paused.
     */
    function transfer(address recipient, uint256 amount) public virtual override whenNotPaused returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);
        super.transfer(recipient, amount);
        return _updateHoldersList(recipient);
        //return true;
    }
    
    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override whenNotPaused returns (bool) {
        super.approve(spender, amount);
        return true;
    }
    
    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override whenNotPaused returns (bool) {
        super.transferFrom(sender, recipient, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual override whenNotPaused returns (bool) {
        super.increaseAllowance(spender, addedValue);
        return true;
    }
    
    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override whenNotPaused returns (bool) {
        super.decreaseAllowance(spender, subtractedValue);
        return true;
    }
    
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
        
        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= cap(), "ERC20Capped: cap exceeded");
        }
        _beforeTokenTransferSnapshot(from, to, amount);
    }
    
    /**
     * @dev Set the cap on the token's total supply.
     */
    function setCap(uint256 amount) public virtual override onlyOwner whenNotPaused returns (bool) {
        require(_msgSender() != address(0),"ERC20Capped: Sender address is 0x");
        require(amount >= totalSupply(),"ERCO20Capped: amount is less than Total Supply");
        
        super.setCap(amount);
        return true;
        
    }
    

    /**
     * @dev Minter Recovery.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function mint(uint256 amount) public virtual override onlyOwner whenNotPaused returns(bool){
        require(totalSupply().add(amount) <= cap(), "ERC20Capped: cap exceeded"); 
        
        super.mint(amount);
        _beforeTokenTransferSnapshot(address(0), _msgSender(), amount);
        return true;
        
    }
    
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual whenNotPaused override {
        super.burn(amount);
        
        _beforeTokenTransferSnapshot(address(0), _msgSender(), amount);
    }
    
    function snapshot() public virtual onlyOwner returns (uint256) {
        return super._snapshot();
    }
    

}



