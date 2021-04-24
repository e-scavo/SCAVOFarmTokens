// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;

import "./SafeMath.sol";
import "./Context.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./Pausable.sol";


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
