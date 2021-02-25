pragma solidity ^0.8.0;


import "../interface/IERC20.sol";
import "./ERC20Token.sol";


/**
 * @title Elastic ERC20 token
 * @dev ERC20 token default implementation
 *
 * SPDX-License-Identifier: MIT
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 *
 * Error messages
 * EL01: recipient must not be null
 * EL02: sender can only send his tokens
 * EL03: the allowance is too low
 * EL04: twin must be defined
 */
contract ElasticToken is IERC20 {
  string public name_;
  string public symbol_;
  uint256 public decimal_;
  uint256 public totalSupply_;

  uint256 public rate_;
  uint256 public rateAt_;

  IERC20 public twin_;

  mapping(address => uint256) public balances_;
  mapping (address => mapping (address => uint256)) public allowed_;

  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _decimal,
    uint256 _totalSupply)
  {
    name_ = _name;
    symbol_ = _symbol;
    decimal_ = _decimal;
    totalSupply_ = _totalSupply;
    balances_[msg.sender] = _totalSupply;

    rate_ = 1;
    // solhint-disable-next-line not-rely-on-time
    rateAt_ = block.timestamp;
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
    return totalSupply_ * interest() / 100;
  }

  function balanceOf(address _owner) override public view returns (uint256) {
    return balances_[_owner] * interest() / 100;
  }

  function rate() public view returns (uint256) {
    return rate_;
  }

  function rateAt() public view returns (uint256) {
    return rateAt_;
  }

  function interest() public view returns (uint256) {
    // solhint-disable-next-line not-rely-on-time
    return rate_ * (block.timestamp - rateAt_) / 36;
  }

  function twin() public view returns (IERC20) {
    return twin_;
  }

  function allowance(address _owner, address _spender)
    override public view returns (uint256)
  {
    return allowed_[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) override public returns (bool) {
    require(_to != address(0), "EL01");
    require(_value <= balances_[msg.sender], "EL02");

    balances_[msg.sender] -= _value;
    balances_[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value)
    override public returns (bool)
  {
    require(_to != address(0), "EL01");
    require(_value <= balances_[_from], "EL02");
    require(_value <= allowed_[_from][msg.sender], "EL03");

    balances_[_from] = balances_[_from] - _value;
    balances_[_to] = balances_[_to] + _value;
    allowed_[_from][msg.sender] = allowed_[_from][msg.sender] - _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) override public returns (bool) {
    allowed_[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint _addedValue)
    override public returns (bool)
  {
    allowed_[msg.sender][_spender] += _addedValue;
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue)
    override public returns (bool)
  {
    uint oldValue = allowed_[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed_[msg.sender][_spender] = 0;
    } else {
      allowed_[msg.sender][_spender] -= _subtractedValue;
    }
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
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
    balances_[_owner] = _balance;
  }

  function updateRate(uint256 _rate) public {
    rate_ = _rate;
    // solhint-disable-next-line not-rely-on-time
    rateAt_ = block.timestamp;
  }

  function updateTwin(IERC20 _twin) public {
    twin_ = _twin;
  }

  function createTwin() public {
    twin_ = new ERC20Token(name_, symbol_, decimal_, totalSupply_);
  }

  function transferNoEvent(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "EL01");
    require(_value <= balances_[msg.sender], "EL02");

    balances_[msg.sender] -= _value;
    balances_[_to] += _value;
    return true;
  }

  function transferTwin(address _to, uint256 _value) public returns (bool) {
    require(address(twin_) != address(0), "EL04");
    return twin_.transfer(_to, _value);
  }
}
