// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
import "./Ownable.sol";
import "./Pausable.sol";

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