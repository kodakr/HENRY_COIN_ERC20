// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ERC_STANDARD {
    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address _owner) public view virtual returns (uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burning(address indexed _from, uint256 indexed _amt);
    event Minting(address indexed _to, uint256 indexed _amt);
    
}

contract Ownership {
    address public owner;
    address public newOwner;
    event TransferOfOwnership(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    function AssignNewOwnership(address _newOwner) public {
        require(msg.sender == owner, "Owner Only Function");
        newOwner = _newOwner;
    }
    function OwnershipAcceptance() public {
        require(msg.sender == newOwner);
        emit TransferOfOwnership(owner, msg.sender);
        owner = newOwner;
        newOwner = address(0);
        
    }
}

contract HenryToken is Ownership, ERC_STANDARD {
    string public _name;
     string public _symbol;
     uint8 public _decimal;
     uint256 public _totalsupply;

     address public _minter;
     mapping(address => uint)Tokenbalances;
     mapping(address => mapping (address => uint)) Approved;

     constructor(address minter) {
        _name = "Henry Coin";
         _symbol = "HRX";
         _totalsupply = 1000000;
         _minter = minter;
         Tokenbalances[minter] = _totalsupply;
     }
       
    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override  returns (string memory) {
        return _symbol;
    }

    function decimals() public view override  returns (uint8){
        return _decimal;
    }

    function totalSupply() public view override  returns (uint256){
        return _totalsupply;
    }

    function balanceOf(address _owner) public view override  returns (uint256 balance) {
        return Tokenbalances[_owner];
       
    }

    function transfer(address _to, uint256 _value) public override  returns (bool success) {
        require(Tokenbalances[ msg.sender] >= _value, "you have Insufficient Balance");
        emit Transfer(msg.sender, _to, _value);
        Tokenbalances[msg.sender] -= _value;
        Tokenbalances[_to] += _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override  returns (bool success) {
        uint allowedBal = Approved[_from][msg.sender];
        require(allowedBal > 0, "u were not assigned this task");
        require(_value <= allowedBal, "exceeded amount");
        Approved[_from][msg.sender] -= _value;
        Tokenbalances[_from] -= _value;
        Tokenbalances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public override  returns (bool success) {
         require(Tokenbalances[msg.sender] >= _value, "insufficient funds");
        Approved[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override  returns (uint256 remaining) {
        return Approved[_owner][_spender];
    }

    function Mint(uint _qty) public returns(bool success) {
        require(msg.sender == _minter, "This function is specific to minter");
        Tokenbalances[_minter] += _qty;
        _totalsupply += _qty;
        emit Minting(msg.sender, _qty);
        return true;
    }

    function Burn(uint _qty) public returns(bool success) {
        require(msg.sender == _minter, "This function is specific to minter");
        Tokenbalances[_minter] -= _qty;
        _totalsupply -= _qty;
        emit Burning(msg.sender, _qty);
        return true;
    }
}
