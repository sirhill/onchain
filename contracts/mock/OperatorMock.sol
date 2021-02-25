pragma solidity ^0.8.0;

import "../governance/Operator.sol";


/**
 * @title OperatorMock
 * @dev Mock the Operator class
 *
 * SPDX-License-Identifier: MIT
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 */
contract OperatorMock is Operator {

  function testOnlyOperator() public onlyOperator view returns (bool) {
    return true;
  }
}
