// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;


// This an abstract of the ERC20 standard
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
/** An Ownership contract enabling the token to be transfered/sold to
a future owner.

Only the current Owner can do this and new owner's consent/ acceptance required to be completed
**/
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

library SafeMath {

   //This returns the addition of two unsigned integers and prevents Overflow by reverting.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    //This returns the subtraction of two unsigned integers. Its implementation prevents Overflow.
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    // This returns the  integer multiplication of two unsigned integers and prevents Overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    
     //Returns the integer division of two unsigned integers. Reverts on
     // division by zero. 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    
     //Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     //Reverts when dividing by zero. 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}





contract HenryToken is Ownership, ERC_STANDARD {
    using SafeMath for uint;
    string public _name;
     string public _symbol;
     uint8 public _decimal;
     uint256 public _totalsupply;

     address public _minter;
     mapping(address => uint256)Tokenbalances;
     mapping(address => mapping (address => uint256)) Approved;

     constructor(address minter) {
        _name = "Henry Coin";
         _symbol = "HRX";
         _totalsupply = 1000000;
         _minter = minter;
         Tokenbalances[minter] = _totalsupply;
     }
       // Returns name of Token
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
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(Tokenbalances[ msg.sender] >= _value, "you have Insufficient Balance");
        emit Transfer(msg.sender, _to, _value);
        Tokenbalances[msg.sender] = Tokenbalances[msg.sender].sub(_value);
        Tokenbalances[_to]  = Tokenbalances[_to].add(_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override  returns (bool success) {
        uint256 allowedBal = Approved[_from][msg.sender]; //if not approved, allowedBal returns 0. hence cant bypass next line.
        require(allowedBal > 0, "u were not assigned this task"); 
        require(_value <= allowedBal, "Exceeds Permitted amount");
        Approved[_from][msg.sender] = Approved[_from][msg.sender].sub(_value);
        Tokenbalances[_from] = Tokenbalances[_from].sub(_value);
        Tokenbalances[_to] = Tokenbalances[_to].add(_value);
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

    function Mint(uint256 _qty) public returns(bool success) {
        require(msg.sender == _minter, "This function is specific to minter");
        Tokenbalances[_minter] = Tokenbalances[_minter].add(_qty);
        _totalsupply = _totalsupply.add(_qty);
        emit Minting(msg.sender, _qty);
        return true;
    }

    function Burn(uint256 _qty) public returns(bool success) {
        require(msg.sender == _minter, "This function is specific to minter");
        Tokenbalances[_minter] = Tokenbalances[_minter].sub(_qty);
        _totalsupply = _totalsupply.sub(_qty);
        emit Burning(msg.sender, _qty);
        return true;
    }
}


contract HenryCoinVendor  is Ownership {
    using SafeMath for uint256;

    HenryToken _myErc20;
    address private Vendor;
    uint256 TokensPerEther = 10;

    event BuyToken(address indexed buyer, uint256 _value, uint256 _tokenqty);
    event SoldToken(address indexed seller, uint256 _howmany, uint256 _amount);
    event Withdrawbalance(address indexed vendor, uint256 balance);

    constructor(address myErc20_) {
        Vendor = msg.sender;
        _myErc20 = HenryToken(myErc20_);
    }

    function buyToken()public payable returns(bool) {
        require(msg.value >= 1 ether, "Min purchase one ethe");
        uint256 _tokenqty = (msg.value.div(1 ether)).mul(TokensPerEther);
        uint256 vendorTokenBal = _myErc20.balanceOf(address(this));
        require(vendorTokenBal >= _tokenqty, "insuficient vendor token");
        (bool sent) = _myErc20.transfer(msg.sender, _tokenqty);
        require(sent, "Token Transfer Faileed");
        emit BuyToken(msg.sender, msg.value, _tokenqty);
        return true;
    }

    function SellToken(uint256 howmany) public payable returns(bool) {
        uint256 _token = howmany.mod(TokensPerEther);
        require(_token == 0, "Must Sell in multiples of 10"); // requires purchace in multiples of ten
        bool VApprov =_myErc20.approve(address(this), howmany); // Function gets owners approval of vendor to spend token
        require(VApprov, "Unable to approve vendor");
        uint qytInEther = howmany.div(TokensPerEther); // calculate vakue equivalent in ETH
        uint vendorbal = (address(this).balance.div(1 ether));
        require(vendorbal >= qytInEther, "Insufficient vendor balance");
        (bool success) = _myErc20.transfer(msg.sender, howmany);
        require(success, "Failed to Transfer from Sender to vendor");
        (bool sent,) = msg.sender.call{value:qytInEther * 1e18} ('');
        require(sent, "Failed to transfer from vendor");
        emit SoldToken(msg.sender, howmany, qytInEther);
        return true;
    }

    // This withdraws all ETH to the Vendors account
    function withdrawal() public payable returns(bool) {
        require(msg.sender == Vendor, "only vendor can do this"); // requires caller to be vendor only
        uint contractBal = address(this).balance;  //gets balance of the smart contract address
        require(contractBal > 0, "empty balance");
        (bool sent,) = Vendor.call{value: contractBal} ('');
        require(sent, "Was unable to withraw to vendor");
        emit Withdrawbalance(msg.sender,  contractBal);
        return true;
    }

}
