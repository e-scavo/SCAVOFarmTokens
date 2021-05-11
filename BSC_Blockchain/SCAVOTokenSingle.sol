// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _creator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRecovered(address indexed creatorOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor() {
        _owner = _msgSender();
        _creator = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: NO");
        _;
    }

    /**
     * @dev Throws if called by any account other than the creator.
     */
    modifier onlyCreator() {
        require(_creator == _msgSender(), "Ownable: NC");
        _;
    }
    
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: NOZA");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    /**
     * @dev Recovers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the creator.
     */
    function recoverOwnership(address newOwner) public virtual onlyCreator {
        require(newOwner != address(0), "Ownable: NOZA");
        emit OwnershipRecovered(newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, Ownable {
    /**
    * @dev Emitted when the pause is triggered by `account`.
    */
    event Paused(address account, uint256 when);

    /**
    * @dev Emitted when the pause is lifted by `account`.
    */
    event Unpaused(address account, uint256 when);

    bool private _paused;

    /**
    * @dev Initializes the contract in unpaused state.
    */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: You cannot execute the requested action while we are paused!.");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() private whenNotPaused onlyOwner {
        _paused = true;
        emit Paused(_msgSender(), block.timestamp);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() private whenPaused onlyOwner {
        _paused = false;
        emit Unpaused(_msgSender(), block.timestamp);
    }
    
    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() public virtual returns(bool) {
        _pause();
        return true;
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() public virtual returns(bool) {
        _unpause();
        return true;
    }
    
}


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity >=0.6.0 <0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    event HasChangedName(address who, string oldName, string newName);
    event HasChangedSymbol(address who, string oldSymbol, string newSymbol);

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_, uint256 initialMintedSupply_) {
        require(initialMintedSupply_ <= totalSupply_,"ERC20: Initial supply > than total");
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = initialMintedSupply_ * (10**decimals_);
        _balances[_msgSender()] = initialMintedSupply_ * (10**decimals_);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    /**
     * @dev Change Token Name
     * 
     * @param newName - new name of the token
     */
     function _setName(string memory newName) internal virtual {
         string memory oldName = _name;
         _name = newName;
         emit HasChangedName(_msgSender(), oldName, newName);
     }

    /**
     * @dev Change Token Symbol
     * 
     * @param newSymbol - New name of the token
     */
     function _setSymbol(string memory newSymbol) internal virtual {
         string memory oldSymbol = _symbol;
         _symbol = newSymbol;
         emit HasChangedSymbol(_msgSender(), oldSymbol, newSymbol);
     }
}


pragma solidity >=0.6.0 <0.8.0;


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


pragma solidity >=0.6.0 <0.8.0;


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


pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
   /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}


pragma solidity >=0.6.0 <0.8.0;


contract SCAVOCompany is Context, Ownable, Pausable
{
    struct sCompany {
        string Name;
        string Country;
        string RegisteredOffice;
        string VAT;
        uint256 IncorporationDate;
        
    }
    sCompany Company;
    
    event HasChangedCompanyName(address indexed who, uint256 when, string fromvalue, string tovalue);
    event HasChangedCompanyCountry(address indexed who, uint256 when, string fromvalue, string tovalue);
    event HasChangedCompanyRegisteredOffice(address indexed who, uint256 when, string fromvalue, string tovalue);
    event HasChangedCompanyVAT(address indexed who, uint256 when, string fromvalue, string tovalue);
    event HasChangedCompanyIncorporationDate(address indexed who, uint256 when, uint256 fromvalue, uint256 tovalue);
    
    constructor()
    {
        sCompany storage c = Company;
        c.Name = "SCAVO Technologies";
        c.Country = "Argentina";
        c.RegisteredOffice = "";
        c.VAT = "";
        c.IncorporationDate = 0;
    }
    /**
     * @dev permits anyone obtain company's information.
     * @return string
     * @return string
     * @return string
     * @return string
     * @return uint256
     */
    function getCompanyData() public view 
    returns(
        string memory,
        string memory,
        string memory,
        string memory,
        uint256
    ){
        return (Company.Name,Company.Country,Company.RegisteredOffice,Company.VAT,Company.IncorporationDate);
    }
    /**
    * @dev set Company's Name
    * @return bool
    */
    function setCompanyName(string memory name) public whenNotPaused onlyOwner returns(bool)
    {
        bytes memory tValue = bytes(name);
        require(tValue.length>0 , "SCAVOCompany: ERR001");
        string memory oldValue = Company.Name;
        Company.Name = name;
        emit HasChangedCompanyName(_msgSender(), block.timestamp, oldValue, name);
        return true;
    }
    /**
    * @dev set Company's Country
    * @return bool
    */
    function setCompanyCountry(string memory country) public whenNotPaused onlyOwner returns(bool)
    {
        bytes memory tValue = bytes(country);
        require(tValue.length>0 , "SCAVOCompany: ERR002");
        string memory oldValue = Company.Country;
        Company.Country = country;
        emit HasChangedCompanyCountry(_msgSender(), block.timestamp, oldValue, country);
        return true;
    }
    /**
    * @dev set Company's Registered Office
    * @return bool
    */
    function setCompanyRegisteredOffice(string memory regoff) public whenNotPaused onlyOwner returns(bool)
    {
        bytes memory tValue = bytes(regoff);
        require(tValue.length>0 , "SCAVOCompany: ERR003");
        string memory oldValue = Company.RegisteredOffice;
        Company.RegisteredOffice = regoff;
        emit HasChangedCompanyRegisteredOffice(_msgSender(), block.timestamp, oldValue, regoff);
        return true;
    }
    /**
    * @dev set Company's VAT
    * @return bool
    */
    function setCompanyVAT(string memory vat) public whenNotPaused onlyOwner returns(bool)
    {
        bytes memory tValue = bytes(vat);
        require(tValue.length>0 , "SCAVOCompany: ERR004");
        string memory oldValue = Company.VAT;
        Company.VAT = vat;
        emit HasChangedCompanyVAT(_msgSender(), block.timestamp, oldValue, vat);
        return true;
    }
    /**
    * @dev set Company's Incorporation Date
    * @return bool
    */
    function setCompanyIncDate(uint256 incdate) public whenNotPaused onlyOwner returns(bool)
    {
        require(incdate>=0 , "SCAVOCompany: ERR005");
        uint256 oldValue = Company.IncorporationDate;
        Company.IncorporationDate = incdate;
        emit HasChangedCompanyIncorporationDate(_msgSender(), block.timestamp, oldValue, incdate);
        return true;
    }
    
}


pragma solidity >=0.6.0 <0.8.0;


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    
}


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity >=0.6.0 <0.8.0;


/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
abstract contract SCAVOTokenBallot is Context, ERC20, Ownable, Pausable {
    using SafeMath for uint256;
    using SafeMath for Proposal;

    event HasCreatedProposal(address indexed who, uint256 createdOn, uint proposalId, string proposalName);
    event HasVotedProposal(address indexed who, uint proposal, uint256 amount, uint256 minVotes, StatusProposals status);
    event HasSucceededProposal(address indexed who, uint proposal, uint256 succeededOn, uint256 withNumberOfVotes);
    event HasCancelledProposal(address indexed who, uint proposal, uint256 cancelledOn, uint256 withNumberOfVotes);
    event HasRejectedProposal(address indexed who, uint proposal, uint256 rejectedOn, uint256 withNumberOfVotes);
    event HasApprovedProposal(address indexed who, uint proposal, uint256 approvedOn, uint256 withNumberOfVotes);
    event HasExecutedProposal(address indexed who, uint proposal, uint256 executedOn, uint256 withNumberOfVotes);
    
    struct Voter {
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
        uint256 votes; // qty of votes;
    }

    enum StatusProposals {
        Created,
        Succeeded,
        Approved,
        Rejected,
        Executed,
        Cancelled,
        Paused
    }
    string[] StatusProposalsString = ["CREATED", "SUCCEEDED", "APPROVED", "REJECTED", "EXECUTED", "CANCELLED", "PAUSED"];
    
    
    struct Proposal {
        uint index; //index on array
        string name;   // short name (up to 32 bytes)
        uint numberOfVoters; //number of voters
        uint256 voteCount; // number of accumulated votes
        StatusProposals status; // status of the proposal
        address createdBy; // address of the creator
        uint256 createdOn;
        address approvedBy;
        uint256 approvedOn;
        address rejectedBy;
        uint256 rejectedOn;
        address executedBy;
        uint256 executedOn;
        address cancelledBy;
        uint256 cancelledOn;
        address succeededBy;
        uint256 succeededOn;
        address pausedBy;
        uint256 pausedOn;
        uint256 minVotes;
    }
    
    mapping(address => mapping (uint => Voter)) private voters;
    
    Proposal[] private _dProposals;
    uint[] private _iProposals; 
    
    /** 
     * @dev Create a new ballot.
     * @param proposalName names of proposal
     * @param minV - minimum votes it requires to succeed
     */
    function addBallot(string memory proposalName, uint256 minV) public virtual whenNotPaused returns(uint)
    {
        bytes memory tName = bytes(proposalName);
        require(tName.length>0 , "SCAVOTokenBallot: proposalName must be given");
        require(minV > 0 && minV <= totalSupply(),"SCAVOTokenBallot: Min. votes required must be > 0 and <= totalSupply");
        uint a = _iProposals.length;
        _iProposals.push();
        _dProposals.push(
            Proposal({
                index : a,
                name: proposalName,
                numberOfVoters: 0,
                voteCount: 0,
                status: StatusProposals.Created,
                createdBy: _msgSender(),
                createdOn: block.timestamp,
                approvedBy: address(0),
                approvedOn: 0,
                rejectedBy: address(0),
                rejectedOn: 0,
                executedBy: address(0),
                executedOn: 0,
                cancelledBy: address(0),
                cancelledOn: 0,
                succeededBy: address(0),
                succeededOn: 0,
                pausedBy: address(0),
                pausedOn: 0,
                minVotes: minV
            })
        );
        emit HasCreatedProposal(_msgSender(), block.timestamp, a, proposalName);
        return a;
    }
    
    /**     * 
     * @dev Give your vote (including votes delegated to you) to proposal '_dProposals[proposal].name'.
     * A Voter is able to vote when the proposal have the following states [Created]
     * @param proposal index of proposal in the _dProposals array
     */
    function voteBallot(uint proposal) public virtual whenNotPaused returns(bool,uint256) {
        Voter storage sender = voters[_msgSender()][proposal];
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(balanceOf(_msgSender()) > 0, "SCAVOTokenBallot: Your balance must be greather than zero.");
        require(!sender.voted, "SCAVOTokenBallot: You have already voted on this proposal.");
        require(_dProposals[proposal].status == StatusProposals.Created, "SCAVOTokenBallot: The proposal is no longer available for voting.");
        
        
        sender.voted = true;
        sender.vote = proposal;

        uint256 a = _dProposals[proposal].voteCount.add(balanceOf(_msgSender()));
        require(a <= totalSupply(),"SCAVOTokenBallot: Number of votes is greather then total supply.");
        _dProposals[proposal].numberOfVoters += 1;
        _dProposals[proposal].voteCount = a;
        
        if(_dProposals[proposal].voteCount >= _dProposals[proposal].minVotes)
        {
            _dProposals[proposal].status = StatusProposals.Succeeded;
            _dProposals[proposal].succeededOn = block.timestamp;
        }
        emit HasVotedProposal(_msgSender(), proposal, balanceOf(_msgSender()), _dProposals[proposal].minVotes, _dProposals[proposal].status);
        if(_dProposals[proposal].status == StatusProposals.Succeeded)
        {
            emit HasSucceededProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        }
        return (true,balanceOf(_msgSender()));
    }
    
    /** 
    * @dev Return a list of ballots.
    * @param `proposal`: index of proposal from array to be returned;
    */
    function getBallot(uint proposal) public view virtual returns(Proposal memory)
    {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        return _dProposals[proposal];
    }
    
    /** 
    * @dev Return a list of ballots.
    */
    function getBallots() public view virtual returns(Proposal[] memory)
    {
        return _dProposals;
    }

    /** 
    * @dev Return a list of ballots by status.
    * @param `status`: status of proposals from array to be returned;
    */
    /* Function disabled for checking on an upgrade smart contract 
    function getBallotsByStatus(uint status) public view virtual returns(Proposal[] memory)
    {
        require(status < StatusProposalsString.length,"SCAVOTokenBallot: Status is invalid.");
        uint c = 0;
        for(uint i=0; i<_dProposals.length; i++)
        {
            if(uint(_dProposals[i].status) == status)
            {
                c += 1;
            }
        }
        Proposal[] memory mProp = new Proposal[](c);
        for(uint i=0; i<_dProposals.length; i++)
        {
            if(uint(_dProposals[i].status) == status)
            {
                c += 1;
                mProp[i] = _dProposals[i];
                //mProp[i] = _dProposals[i];
                
            }
        }
        return mProp;
    }
    */
    //["0 = CREATED", "1 = SUCCEEDED", " 2 = APPROVED", "3 = REJECTED", "4 = EXECUTED", "5 = CANCELLED", "6 = PAUSED"]
    /**
    * Changes on status based on current `status`.
    * Cancelled => [Created, Succeeded, Paused]
    * Succeeded => [Created && Votes >= MinVotes, Paused && Votes >= MinVotes]
    * Approved => [Succeeded, Paused && Votes >= MinVotes]
    * Rejected => [Approved]
    * Executed => [Approved]
    * Paused => [Created, Succeeded, Approved]
    *
    * /
    /**
     * @dev Permit to Pause a proposal to proposal '_dProposals[proposal].name'.
     * The ballot can be `rejected` if the above requirements are met.
     * @param proposal uint index of proposal in the _dProposals array
     * @param reason string of why you want to change the state of the proposal.
     * @return bool
     */
    function PauseBallot(uint proposal, string memory reason) public virtual whenNotPaused returns(bool) {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(_msgSender() == owner() , "SCAVOTokenBallot: Only the owner can pause the proposal.");
        require(_dProposals[proposal].status != StatusProposals.Paused, "SCAVOTokenBallot: Proposal is already paused.");
        require(_dProposals[proposal].status == StatusProposals.Created ||
                _dProposals[proposal].status == StatusProposals.Succeeded ||
                _dProposals[proposal].status == StatusProposals.Approved
                , "SCAVOTokenBallot: You can pause a proposal if it is [Created, Succeeded, Approved].");
        bytes memory tReason = bytes(reason);
        require(tReason.length>0 , "SCAVOTokenBallot: To proceed, you must enter a valid reason.");

        _dProposals[proposal].status = StatusProposals.Paused;
        _dProposals[proposal].pausedOn = block.timestamp;
        _dProposals[proposal].pausedBy = _msgSender();
        //_dProposals[proposal].pausedReason = reason;
        emit HasExecutedProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        return (true);
    }
    /**
     * @dev Permit to Reject a proposal to proposal '_dProposals[proposal].name'.
     * The ballot can be `rejected` if the above requirements are met.
     * @param proposal uint index of proposal in the _dProposals array
     * @param reason string of why you want to change the state of the proposal.
     * @return bool
     */
    function ExecuteBallot(uint proposal, string memory reason) public virtual whenNotPaused returns(bool) {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(_msgSender() == owner() , "SCAVOTokenBallot: Only the owner can execute the proposal.");
        require(_dProposals[proposal].status != StatusProposals.Executed, "SCAVOTokenBallot: Proposal is already executed.");
        require(_dProposals[proposal].status == StatusProposals.Approved, "SCAVOTokenBallot: You can execute a proposal if it is [Approved].");
        bytes memory tReason = bytes(reason);
        require(tReason.length>0 , "SCAVOTokenBallot: To proceed, you must enter a valid reason.");

        _dProposals[proposal].status = StatusProposals.Executed;
        _dProposals[proposal].executedOn = block.timestamp;
        _dProposals[proposal].executedBy = _msgSender();
        //_dProposals[proposal].executedReason = reason;
        emit HasExecutedProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        return (true);
    }
    /**
     * @dev Permit to Reject a proposal to proposal '_dProposals[proposal].name'.
     * The ballot can be `rejected` if the above requirements are met.
     * @param proposal uint index of proposal in the _dProposals array
     * @param reason string of why you want to change the state of the proposal.
     * @return bool
     */
    function RejectBallot(uint proposal, string memory reason) public virtual whenNotPaused returns(bool) {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(_msgSender() == owner() , "SCAVOTokenBallot: Only the owner can reject the proposal.");
        require(_dProposals[proposal].status != StatusProposals.Rejected, "SCAVOTokenBallot: Proposal is already rejected.");
        require(_dProposals[proposal].status == StatusProposals.Approved, "SCAVOTokenBallot: You can reject a proposal if it is [Approved].");
        bytes memory tReason = bytes(reason);
        require(tReason.length>0 , "SCAVOTokenBallot: To proceed, you must enter a valid reason.");

        _dProposals[proposal].status = StatusProposals.Rejected;
        _dProposals[proposal].rejectedOn = block.timestamp;
        _dProposals[proposal].rejectedBy = _msgSender();
        //_dProposals[proposal].rejectedReason = reason;
        emit HasRejectedProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        return (true);
    }
    /**
     * @dev Permit to Aprrove a proposal to proposal '_dProposals[proposal].name'.
     * The ballot can be `approved` if the above requirements are met.
     * @param proposal uint index of proposal in the _dProposals array
     * @param reason string of why you want to change the state of the proposal.
     * @return bool
     */
    function ApproveBallot(uint proposal, string memory reason) public virtual whenNotPaused returns(bool) {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(_msgSender() == owner() , "SCAVOTokenBallot: Only the owner can approve the proposal.");
        require(_dProposals[proposal].status != StatusProposals.Approved, "SCAVOTokenBallot: Proposal is already approved.");
        require((_dProposals[proposal].status == StatusProposals.Succeeded) || 
                (_dProposals[proposal].status == StatusProposals.Paused && _dProposals[proposal].voteCount >= _dProposals[proposal].minVotes)
                , "SCAVOTokenBallot: You can approve a proposal if it is [Succeeded, Paused && Votes >= MinVotes].");
        bytes memory tReason = bytes(reason);
        require(tReason.length>0 , "SCAVOTokenBallot: To proceed, you must enter a valid reason.");

        _dProposals[proposal].status = StatusProposals.Approved;
        _dProposals[proposal].approvedOn = block.timestamp;
        _dProposals[proposal].approvedBy = _msgSender();
        //_dProposals[proposal].approvedReason = reason;
        emit HasApprovedProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        return (true);
    }
    /**
     * @dev Permit to Succeed a proposal to proposal '_dProposals[proposal].name'.
     * The ballot can be `succeeded` if the above requirements are met.
     * @param proposal uint index of proposal in the _dProposals array
     * @param reason string of why you want to change the state of the proposal.
     * @return bool
     */
    function SucceedBallot(uint proposal, string memory reason) public virtual whenNotPaused returns(bool) {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(_msgSender() == owner() , "SCAVOTokenBallot: Only the owner can succeed the proposal.");
        require(_dProposals[proposal].status != StatusProposals.Succeeded, "SCAVOTokenBallot: Proposal is already succeeded.");
        require((_dProposals[proposal].status == StatusProposals.Created && _dProposals[proposal].voteCount >= _dProposals[proposal].minVotes) || 
                (_dProposals[proposal].status == StatusProposals.Paused && _dProposals[proposal].voteCount >= _dProposals[proposal].minVotes)
                , "SCAVOTokenBallot: You can succeed a proposal if it is [Created && Votes >= MinVotes, Paused && Votes >= MinVotes].");
        bytes memory tReason = bytes(reason);
        require(tReason.length>0 , "SCAVOTokenBallot: To proceed, you must enter a valid reason.");

        _dProposals[proposal].status = StatusProposals.Succeeded;
        _dProposals[proposal].succeededOn = block.timestamp;
        _dProposals[proposal].succeededBy = _msgSender();
        //_dProposals[proposal].succeededReason = reason;
        emit HasSucceededProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        return (true);
    }
    /**
     * @dev Permit to Cancel proposal to proposal '_dProposals[proposal].name'.
     * The ballot can be `cancelled` if the above requirements are met.
     * @param proposal uint index of proposal in the _dProposals array
     * @param reason string of why you want to change the state of the proposal.
     * @return bool
     */
    function CancelBallot(uint proposal, string memory reason) public virtual whenNotPaused returns(bool) {
        require(proposal < _dProposals.length, "SCAVOTokenBallot: You have entered an invalid proposal.");
        require(_dProposals[proposal].createdBy == _msgSender() || _dProposals[proposal].createdBy == owner() , "SCAVOTokenBallot: Only the proposal's creator or owner can cancel the proposal.");
        require(_dProposals[proposal].status != StatusProposals.Cancelled, "SCAVOTokenBallot: Proposal is already cancelled.");
        require(_dProposals[proposal].status == StatusProposals.Created || 
                _dProposals[proposal].status == StatusProposals.Succeeded ||
                _dProposals[proposal].status == StatusProposals.Paused
                , "SCAVOTokenBallot: You can cancel a proposal if it is (Created|Succeeded|Paused).");
        bytes memory tReason = bytes(reason);
        require(tReason.length>0 , "SCAVOTokenBallot: To proceed, you must enter a valid reason.");

        _dProposals[proposal].status = StatusProposals.Cancelled;
        _dProposals[proposal].cancelledOn = block.timestamp;
        _dProposals[proposal].cancelledBy = _msgSender();
        //_dProposals[proposal].cancelledReason = reason;
        emit HasCancelledProposal(_msgSender(), proposal, block.timestamp, _dProposals[proposal].voteCount);
        return (true);
    }
    
    

}

pragma solidity >=0.6.0 <0.8.0;


abstract contract SCAVOTokenAdvanced is Context, ERC20, Ownable, Pausable
{
    using SafeMath for uint256;
    mapping(address => uint) private _iHolders;
    address[] private _aHolders;
    address[] private _aStolen;
    
    constructor()
    {
        _aHolders.push(address(0));
    }
    
    /**
    * @dev Function to add a holder when `balanceOf(account)` == 0.
    * 
    * @param `account`
    * @return bool
    */
    function _addHolder(address account) private returns(bool)
    {
        if(!_inArray(account))
        {
            _iHolders[account] = _aHolders.length;
            _aHolders.push(account);
            return true;
        }
        return false;
    }
    
    /**
    * @dev Function to check if a holder exists in array
    * 
    * @param `account`
    * @return bool
    */
    function _inArray(address account) private view returns(bool)
    {
        if(account != address(0) && _iHolders[account]>0)
        {
            return true;
        }
        return false;
    }


    /**
    * @dev Function to remove a holder when `balanceOf(account)` == 0.
    * 
    * @param `account`
    * @return bool
    */
    function _remHolder(address account) private returns(bool)
    {
        if(!_inArray(account))
        {
            return true;
        }else
        {
            uint cPos = _iHolders[account];
            delete _aHolders[cPos];
            for (uint i = cPos; i<_aHolders.length-1; i++)
            {
                _aHolders[i] = _aHolders[i+1];
            }
            _aHolders.pop();
            return true;
        }
    }
    
    /**
    * @dev Function update the Holder List on every token transaction.
    * 
    * @param account - Account destination - Origin is already knwon by _msgSend().
    * @return bool
    */
    function _updateHoldersList(address account) internal virtual returns(bool)
    {
        bool a = false;
        if(balanceOf(account) > 0)
        {
            a = _addHolder(account);
        }else
        {
            a = _remHolder(account);
        }
        if(balanceOf(_msgSender()) > 0)
        {
            a = _addHolder(_msgSender());
        }else
        {
            a = _remHolder(_msgSender());
        }
        return a;
    }
    
    /**
    * @dev Function to return all the token holders that has balance at anytime.
    * 
    * @return address[] - Array of holders
    * @return uint - Number of holders in the array.
    */
    function getHolders() public view virtual returns(address[] memory , uint )
    {
        address[] memory vHolders = new address[](_aHolders.length-1);
        uint j = 0;
        for(uint i=0; i<_aHolders.length; i++)
        {
            if(_aHolders[i] != address(0))
            {
                vHolders[j] = _aHolders[i];
                j++;
            }
        }
        return (vHolders, vHolders.length);
    }
    
    /**
     * @dev Change Token Name
     * 
     * @param newName - new name of the token
     */
     function setName(string memory newName) public onlyOwner whenNotPaused {
        require(bytes(newName).length>0,"ERC20: ERR001");
        _setName(newName);
     }
    
    /**
     * @dev Change Token Symbol
     * 
     * @param newSymbol - New name of the token
     */
     function setSymbol(string memory newSymbol) public onlyOwner whenNotPaused {
        require(bytes(newSymbol).length>0,"ERC20: ERR002");
        _setSymbol(newSymbol);
     }
    
}


pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }
}




pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */
abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }


    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransferSnapshot(address from, address to, uint256 amount) internal virtual {
      super._beforeTokenTransfer(from, to, amount);

      if (from == address(0)) {
        // mint
        _updateAccountSnapshot(to);
        _updateTotalSupplySnapshot();
      } else if (to == address(0)) {
        // burn
        _updateAccountSnapshot(from);
        _updateTotalSupplySnapshot();
      } else {
        // transfer
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);
      }
    }
    
    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        // solhint-disable-next-line max-line-length
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}



pragma solidity >=0.6.0 <0.8.0;


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



