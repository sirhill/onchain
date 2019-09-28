pragma solidity >=0.5.0 <0.6.0;


import "../interface/IERC20.sol";
import "../math/SafeMath.sol";
import "./ERC20Token.sol";


/**
 * @title Dummy ERC20 token
 * @dev ERC20 token default implementation
 */
contract DummyToken is IERC20 {
  using SafeMath for uint256;

  string public name_;
  string public symbol_;
  uint256 public decimal_;
  uint256 public totalSupply_;

  uint256 public rate_;
  uint256 public rateAt_;

  IERC20 twin_;

  mapping(address => uint256) private balances;

  mapping (address => mapping (address => uint256)) internal allowed;

  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _decimal,
    uint256 _totalSupply) public
  {
    name_ = _name;
    symbol_ = _symbol;
    decimal_ = _decimal;
    totalSupply_ = _totalSupply;
    balances[msg.sender] = _totalSupply;

    rate_ = 1;
    rateAt_ = now;
  }

  function name() public view returns (string memory) {
    return name_;
  }

  function symbol() public view returns (string memory) {
    return symbol_;
  }

  function decimal() public view returns (uint256) {
    return decimal_;
  }

  function totalSupply() public view returns (uint256) {
    return totalSupply_.mul(interest()).div(100);
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner].mul(interest()).div(100);
  }

  function rate() public view returns (uint256) {
    return rate_;
  }

  function rateAt() public view returns (uint256) {
    return rateAt_;
  }

  function interest() public view returns (uint256) {
    return rate_.mul(now - rateAt_).div(36);
  }

  function twin() public view returns (IERC20) {
    return twin_;
  }

  function allowance(address _owner, address _spender)
    public view returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint _addedValue)
    public returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue)
    public returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function updateToken(string memory _name, string memory _symbol, uint256 _decimal) public {
    name_ = _name;
    symbol_ = _symbol;
    decimal_ = _decimal;
  }

  function updateSupply(uint256 _totalSupply) public {
    totalSupply_ = _totalSupply;
  }

  function updateBalance(address _owner, uint256 _balance) public {
    balances[_owner] = _balance;
  }

  function updateRate(uint256 _rate) public {
    rate_ = _rate;
    rateAt_ = now;
  }

  function updateTwin(IERC20 _twin) public {
    twin_ = _twin;
  }

  function createTwin() public {
    twin_ = new ERC20Token(name_, symbol_, decimal_, totalSupply_);
  }

  function transferNoEvent(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    return true;
  }

  function transferTwin(address _to, uint256 _value) public returns (bool) {
    require(address(twin_) != address(0));
    return twin_.transfer(_to, _value);
  }
}
