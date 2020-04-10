'user strict';

/**
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 */

const assertRevert = require('../helpers/assertRevert');
const OperatorMock = artifacts.require('../../contracts/mock/OperatorMock.sol');

const OPERATOR = web3.utils.toHex('OPERATOR').padEnd(66, '0');
const OPERATOR1 = web3.utils.toHex('OPERATOR1').padEnd(66, '0');
const OPERATOR2 = web3.utils.toHex('OPERATOR2').padEnd(66, '0');

const LEGAL = web3.utils.toHex('LEGAL').padEnd(66, '0');
const REGULATOR = web3.utils.toHex('REGULATOR').padEnd(66, '0');

contract('Operator', function (accounts) {
  let operator;

  beforeEach(async function () {
    operator = await OperatorMock.new();
  });

  it('should have no operator', async function () {
    const operatorCount = await operator.operatorCount();
    assert.equal(operatorCount, 0, 'count');
  });

  it('should allow owner to set a new operator', async function () {
    const tx = await operator.defineOperators([ OPERATOR ], [ accounts[2] ]);
    assert.ok(tx.receipt.status, 'status');
    assert.equal(tx.logs.length, 2);
    assert.equal(tx.logs[0].event, 'OperatorsCleared');
    assert.equal(tx.logs[0].args.size, 0);
    assert.equal(tx.logs[1].event, 'OperatorDefined');
    assert.equal(tx.logs[1].args.name, OPERATOR);
    assert.equal(tx.logs[1].args._address, accounts[2]);
  });

  it('should allow owner to set new operators', async function () {
    const tx = await operator.defineOperators([ OPERATOR1, OPERATOR2 ], [ accounts[2], accounts[3] ]);
    assert.ok(tx.receipt.status, 'status');
    assert.equal(tx.logs.length, 3);
    assert.equal(tx.logs[0].event, 'OperatorsCleared');
    assert.equal(tx.logs[0].args.size, 0);
    assert.equal(tx.logs[1].event, 'OperatorDefined');
    assert.equal(tx.logs[1].args.name, OPERATOR1);
    assert.equal(tx.logs[1].args._address, accounts[2]);
    assert.equal(tx.logs[2].event, 'OperatorDefined');
    assert.equal(tx.logs[2].args.name, OPERATOR2);
    assert.equal(tx.logs[2].args._address, accounts[3]);
  });

  it('should not allow owner to set new operators with wrong operator/name count', async function () {
    await assertRevert(operator.defineOperators([ OPERATOR, OPERATOR2 ], [ accounts[2] ]));
  });

  it('should not allow non owner to set a new operator', async function () {
    await assertRevert(operator.defineOperators([ OPERATOR ], [ accounts[2] ], { from: accounts[4] }));
  });

  describe('with authorities defined', function () {
    beforeEach(async function () {
      await operator.defineOperators([ LEGAL, REGULATOR ], [ accounts[1], accounts[2] ]);
    });

    it('should have two operators', async function () {
      const count = await operator.operatorCount();
      assert.equal(count, 2, 'count');
    });

    it('should return accounts1 for operator1', async function () {
      const op1 = await operator.operatorAddress(0);
      assert.equal(op1, accounts[1], 'account 1');
    });

    it('should return accounts1 for operator2', async function () {
      const op2 = await operator.operatorAddress(1);
      assert.equal(op2, accounts[2], 'account 2');
    });

    it('should allow operator1 through onlyOperator modifier', async function () {
      await operator.testOnlyOperator({ from: accounts[1] });
    });

    it('should allow operator2 through onlyOperator modifier', async function () {
      await operator.testOnlyOperator({ from: accounts[2] });
    });

    it('should not allow non operator through onlyOperator modifier', async function () {
      await assertRevert(operator.testOnlyOperator());
    });

    it('should allow owner to set a new operator', async function () {
      const tx = await operator.defineOperators([ OPERATOR ], [ accounts[2] ]);
      assert.ok(tx.receipt.status, 'status');
      assert.equal(tx.logs.length, 2);
      assert.equal(tx.logs[0].event, 'OperatorsCleared');
      assert.equal(tx.logs[0].args.size, 2);
      assert.equal(tx.logs[1].event, 'OperatorDefined');
      assert.equal(tx.logs[1].args.name, OPERATOR);
      assert.equal(tx.logs[1].args._address, accounts[2]);
    });
  });
});
