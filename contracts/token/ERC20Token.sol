pragma solidity ^0.8.0;


import "../interface/IERC20.sol";


/**
 * @title ERC20 token
 * @dev ERC20 token default implementation
 *
 * SPDX-License-Identifier: MIT
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 */
contract ERC20Token is IERC20 {
  string public name_;
  string public symbol_;
  uint256 public decimal_;
  uint256 public totalSupply_;

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
    return balances_[_owner];
  }

  function allowance(address _owner, address _spender)
    override public view returns (uint256)
  {
    return allowed_[_owner][_spender];
  }

  function transfer(address _to, uint256 _value)
    override public returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances_[msg.sender]);

    balances_[msg.sender] -= _value;
    balances_[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value)
    override public returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances_[_from]);
    require(_value <= allowed_[_from][msg.sender]);

    balances_[_from] -= _value;
    balances_[_to] += _value;
    allowed_[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value)
    override public returns (bool)
  {
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
}
