pragma solidity >=0.5.0 <0.6.0;


import "../governance/Operator.sol";

/**
 * @title OperatorMock
 * @dev Mock the Operator class
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 */
contract OperatorMock is Operator {

  function testOnlyOperator() public onlyOperator view returns (bool) {
    return true;
  }
}
