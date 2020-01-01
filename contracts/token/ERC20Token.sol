pragma solidity >=0.6.0 <0.7.0;


import "../interface/IERC20.sol";
import "../math/SafeMath.sol";


/**
 * @title ERC20 token
 * @dev ERC20 token default implementation
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 */
contract ERC20Token is IERC20 {
  using SafeMath for uint256;

  string private name_;
  string private symbol_;
  uint256 private decimal_;
  uint256 private totalSupply_;

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
  }

  function name() override public view returns (string memory) {
    return name_;
  }

  function symbol() override public view returns (string memory) {
    return symbol_;
  }

  function decimal() override public view returns (uint256) {
    return decimal_;
  }

  function totalSupply() override public view returns (uint256) {
    return totalSupply_;
  }

  function balanceOf(address _owner) override public view returns (uint256) {
    return balances[_owner];
  }

  function allowance(address _owner, address _spender)
    override public view returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  function transfer(address _to, uint256 _value)
    override public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value)
    override public returns (bool)
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

  function approve(address _spender, uint256 _value)
    override public returns (bool)
  {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint _addedValue)
    override public returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue)
    override public returns (bool)
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
}
