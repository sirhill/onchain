pragma solidity ^0.6.0;

import "../governance/Operator.sol";
import "../interface/IUserRegistry.sol";


/**
 * @title UserRegistry
 * @dev UserRegistry contract
 * Configure and manage users_
 * Extended may be used externaly to store data within a user context
 *
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 *
 * Error messages
 * UR01: UserId is invalid
 * UR02: WalletOwner is already known
 * UR03: Users length does not match with addresses
 * UR04: WalletOwner is unknown
 * UR05: Sender is not the wallet owner
 * UR06: User is already suspended
 * UR07: User is not suspended
*/
contract UserRegistry is IUserRegistry, Operator {

  struct User {
    uint256 validUntilTime;
    bool suspended;
    mapping(uint256 => uint256) extended;
  }

  mapping(uint256 => User) public users_;
  mapping(address => uint256) public walletOwners_;
  uint256 public userCount_;

  /**
   * @dev contructor
   **/
  constructor(address[] memory _addresses, uint256 _validUntilTime) public {
    for (uint256 i = 0; i < _addresses.length; i++) {
      _registerUserInternal(_addresses[i], _validUntilTime);
    }
  }

  /**
   * @dev number of user registered
   */
  function userCount() override public view returns (uint256) {
    return userCount_;
  }

  /**
   * @dev the userId associated to the provided address
   */
  function userId(address _address) override public view returns (uint256) {
    return walletOwners_[_address];
  }

  /**
   * @dev the userId associated to the provided address if the user is valid
   */
  function validUserId(address _address) override public view returns (uint256) {
    uint256 addressUserId = walletOwners_[_address];
    if (_isValidInternal(users_[addressUserId])) {
      return addressUserId;
    }
    return 0;
  }

  /**
   * @dev returns the time at which user validity ends
   */
  function validUntilTime(uint256 _userId) override public view returns (uint256) {
    return users_[_userId].validUntilTime;
  }

  /**
   * @dev is the user suspended
   */
  function suspended(uint256 _userId) override public view returns (bool) {
    return users_[_userId].suspended;
  }

  /**
   * @dev access to extended user data
   */
  function extended(uint256 _userId, uint256 _key)
    override public view returns (uint256)
  {
    return users_[_userId].extended[_key];
  }

  /**
   * @dev validity of the current user
   */
  function isAddressValid(address _address) override public view returns (bool) {
    return _isValidInternal(users_[walletOwners_[_address]]);
  }

  /**
   * @dev validity of the current user
   */
  function isValid(uint256 _userId) override public view returns (bool) {
    return _isValidInternal(users_[_userId]);
  }

  /**
   * @dev register a user
   */
  function registerUser(address _address, uint256 _validUntilTime)
    override public onlyOperator
  {
    _registerUserInternal(_address, _validUntilTime);
  }

  /**
   * @dev register many users_
   */
  function registerManyUsers(address[] memory _addresses, uint256 _validUntilTime)
    override public onlyOperator
  {
    for (uint256 i = 0; i < _addresses.length; i++) {
      _registerUserInternal(_addresses[i], _validUntilTime);
    }
  }

  /**
   * @dev attach an address with a user
   */
  function attachAddress(uint256 _userId, address _address)
    override public onlyOperator
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    require(walletOwners_[_address] == 0, "UR02");
    walletOwners_[_address] = _userId;

    emit AddressAttached(_userId, _address);
  }

  /**
   * @dev attach many addresses to many users_
   */
  function attachManyAddresses(uint256[] memory _userIds, address[] memory _addresses)
    override public onlyOperator
  {
    require(_addresses.length == _userIds.length, "UR03");
    for (uint256 i = 0; i < _addresses.length; i++) {
      attachAddress(_userIds[i], _addresses[i]);
    }
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachAddress(address _address)
    override public onlyOperator
  {
    _detachAddressInternal(_address);
  }

  /**
   * @dev detach many addresses association between addresses and their respective users_
   */
  function detachManyAddresses(address[] memory _addresses)
    override public onlyOperator
  {
    for (uint256 i = 0; i < _addresses.length; i++) {
      _detachAddressInternal(_addresses[i]);
    }
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachSelf() override public {
    _detachAddressInternal(msg.sender);
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachSelfAddress(address _address) override public {
    uint256 senderUserId = walletOwners_[msg.sender];
    require(walletOwners_[_address] == senderUserId, "UR05");
    _detachAddressInternal(_address);
  }

  /**
   * @dev suspend a user
   */
  function suspendUser(uint256 _userId) override public onlyOperator {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    require(!users_[_userId].suspended, "UR06");
    users_[_userId].suspended = true;
  }

  /**
   * @dev unsuspend a user
   */
  function unsuspendUser(uint256 _userId) override public onlyOperator {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    require(users_[_userId].suspended, "UR07");
    users_[_userId].suspended = false;
  }

  /**
   * @dev suspend many users_
   */
  function suspendManyUsers(uint256[] memory _userIds)
    override public onlyOperator
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      suspendUser(_userIds[i]);
    }
  }

  /**
   * @dev unsuspend many users_
   */
  function unsuspendManyUsers(uint256[] memory _userIds)
    override public onlyOperator
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      unsuspendUser(_userIds[i]);
    }
  }

  /**
   * @dev update a user
   */
  function updateUser(
    uint256 _userId,
    uint256 _validUntilTime,
    bool _suspended) override public onlyOperator
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    users_[_userId].validUntilTime = _validUntilTime;
    users_[_userId].suspended = _suspended;
  }

  /**
   * @dev update many users_
   */
  function updateManyUsers(
    uint256[] memory _userIds,
    uint256 _validUntilTime,
    bool _suspended) override public onlyOperator
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUser(_userIds[i], _validUntilTime, _suspended);
    }
  }

  /**
   * @dev update user extended information
   */
  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    override public onlyOperator
  {
    require(_userId > 0 && _userId <= userCount_, "UR01");
    users_[_userId].extended[_key] = _value;
  }

  /**
   * @dev update many user extended informations
   */
  function updateManyUsersExtended(
    uint256[] memory _userIds,
    uint256 _key,
    uint256 _value) override public onlyOperator
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUserExtended(_userIds[i], _key, _value);
    }
  }

  /**
   * @dev register a user
   */
  function _registerUserInternal(address _address, uint256 _validUntilTime)
    internal
  {
    require(walletOwners_[_address] == 0, "UR03");
    users_[++userCount_] = User(_validUntilTime, false);
    walletOwners_[_address] = userCount_;

    emit UserRegistered(userCount_);
    emit AddressAttached(userCount_, _address);
  }

  /**
   * @dev detach the association between an address and its user
   */
  function _detachAddressInternal(address _address) internal {
    uint256 addressUserId = walletOwners_[_address];
    require(addressUserId != 0, "UR04");
    emit AddressDetached(addressUserId, _address);
    delete walletOwners_[_address];
  }

  /**
   * @dev validity of the current user
   */
  function _isValidInternal(User storage user) internal view returns (bool) {
    // solhint-disable-next-line not-rely-on-time
    return !user.suspended && user.validUntilTime > now;
  }
}
