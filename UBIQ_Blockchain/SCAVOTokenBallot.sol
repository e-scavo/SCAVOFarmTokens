// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Context.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./Pausable.sol";

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