'user strict';

/**
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * Copyright © 2016 - 2019, All Rights Reserved.
 * This content cannot be used, copied or reproduced in part or in whole
 * without the express and written permission of its author.
 * All matters regarding the intellectual property of this code or software
 * are subjects to Swiss Law without reference to its conflicts of law rules.
 *
 */

const assertRevert = require('../helpers/assertRevert');
const ERC20Token = artifacts.require('../../contracts/token/ERC20Token');
const BN = web3.utils.BN;

const TOTAL_SUPPLY = new BN('10000000000000000000000').toString();

contract('ERC20Token', function (accounts) {
  const account0 = accounts[0];
  const account1 = accounts[1];

  let token;

  beforeEach(async function () {
    token = await ERC20Token.new('Test', 'TST', 18, TOTAL_SUPPLY);
  });

  it('should have a name', async function () {
    const name = await token.name();
    assert.equal(name, 'Test', 'name');
  });

  it('should have a symbol', async function () {
    const symbol = await token.symbol();
    assert.equal(symbol, 'TST', 'symbol');
  });

  it('should have decimal', async function () {
    const decimal = await token.decimal();
    assert.equal(decimal, 18, 'decimal');
  });

  it('should have total supply', async function () {
    const totalSupply = await token.totalSupply();
    assert.equal(totalSupply, TOTAL_SUPPLY, 'total supply');
  });

  it('should have allocated all tokens in account0 balance', async function () {
    const balance0 = await token.balanceOf(account0);
    assert.equal(balance0, TOTAL_SUPPLY, 'balance0');

    const balance1 = await token.balanceOf(account1);
    assert.equal(balance1, 0, 'balance1');
  });

  it('should have no allowance for account1 on account0', async function () {
    const allowanceOn0From1 = await token.allowance(account0, account1);
    assert.equal(allowanceOn0From1, 0, 'allowance on account 0 from account 1');
  });

  it('should let transfer 0 tokens', async function () {
    const receipt = await token.transfer(account1, 0);
    assert.equal(receipt.logs.length, 1);
    assert.equal(receipt.logs[0].event, 'Transfer');
    assert.equal(receipt.logs[0].args.from, account0);
    assert.equal(receipt.logs[0].args.to, account1);
    assert.equal(receipt.logs[0].args.value, 0);
  });

  it('should let transfer some tokens', async function () {
    const receipt = await token.transfer(account1, '100000000');
    assert.equal(receipt.logs.length, 1);
    assert.equal(receipt.logs[0].event, 'Transfer');
    assert.equal(receipt.logs[0].args.from, account0);
    assert.equal(receipt.logs[0].args.to, account1);
    assert.equal(receipt.logs[0].args.value, '100000000');
  });

  describe('With some tokens transfered to account1', async function () {
    beforeEach(async function () {
      await token.transfer(account1, '100000000');
    });

    it('should have the same total supply', async function () {
      const totalSupply = await token.totalSupply();
      assert.equal(totalSupply, TOTAL_SUPPLY, 'total supply');
    });

    it('should have account0 with a smaller balance', async function () {
      const balance0 = await token.balanceOf(account0);
      assert.equal(balance0.toString(), '9999999999999900000000', 'balance1');
    });

    it('should have account1 with a non empty balance', async function () {
      const balance1 = await token.balanceOf(account1);
      assert.equal(balance1, '100000000', 'balance1');
    });
  });

  it('should let approve some tokens to account1', async function () {
    const receipt = await token.approve(account1, 1000);
    assert.equal(receipt.logs.length, 1);
    assert.equal(receipt.logs[0].event, 'Approval');
    assert.equal(receipt.logs[0].args.owner, account0);
    assert.equal(receipt.logs[0].args.spender, account1);
    assert.equal(receipt.logs[0].args.value, 1000);
  });

  describe('With an allowance to account1 on account0', async function () {
    beforeEach(async function () {
      await token.approve(account1, 1000);
    });

    it('should let account1 transferFrom account0 token', async function () {
      const receipt = await token.transferFrom(account0, accounts[2], 1000, { from: account1 });
      assert.equal(receipt.logs.length, 1);
      assert.equal(receipt.logs[0].event, 'Transfer');
      assert.equal(receipt.logs[0].args.from, account0);
      assert.equal(receipt.logs[0].args.to, accounts[2]);
      assert.equal(receipt.logs[0].args.value, 1000);
    });

    it('should not let account1 transfer from account0 too many tokens', async function () {
      await assertRevert(token.transferFrom(account0, accounts[2], 1001, { from: account1 }));
    });

    it('should allow decrease allowance', async function () {
      const receipt = await token.decreaseApproval(account1, 500);
      assert.equal(receipt.logs.length, 1);
      assert.equal(receipt.logs[0].event, 'Approval');
      assert.equal(receipt.logs[0].args.owner, account0);
      assert.equal(receipt.logs[0].args.spender, account1);
      assert.equal(receipt.logs[0].args.value, 500);
    });

    it('should allow over decrease allowance', async function () {
      const receipt = await token.decreaseApproval(account1, 1000);
      assert.equal(receipt.logs.length, 1);
      assert.equal(receipt.logs[0].event, 'Approval');
      assert.equal(receipt.logs[0].args.owner, account0);
      assert.equal(receipt.logs[0].args.spender, account1);
      assert.equal(receipt.logs[0].args.value, 0);
    });

    it('should allow increase allowance', async function () {
      const receipt = await token.increaseApproval(account1, 500);
      assert.equal(receipt.logs.length, 1);
      assert.equal(receipt.logs[0].event, 'Approval');
      assert.equal(receipt.logs[0].args.owner, account0);
      assert.equal(receipt.logs[0].args.spender, account1);
      assert.equal(receipt.logs[0].args.value, 1500);
    });
  });
});
