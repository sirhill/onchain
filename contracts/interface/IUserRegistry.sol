pragma solidity ^0.6.0;


/**
 * @title IUserRegistry
 * @dev IUserRegistry interface
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 **/
abstract contract IUserRegistry {

  event UserRegistered(uint256 indexed userId);
  event AddressAttached(uint256 indexed userId, address address_);
  event AddressDetached(uint256 indexed userId, address address_);

  function userCount() virtual public view returns (uint256);
  function userId(address _address) virtual public view returns (uint256);
  function validUserId(address _address) virtual public view returns (uint256);
  function validUntilTime(uint256 _userId) virtual public view returns (uint256);
  function suspended(uint256 _userId) virtual public view returns (bool);
  function extended(uint256 _userId, uint256 _key)
    virtual public view returns (uint256);

  function isAddressValid(address _address) virtual public view returns (bool);
  function isValid(uint256 _userId) virtual public view returns (bool);

  function registerUser(address _address, uint256 _validUntilTime) virtual public;
  function registerManyUsers(address[] memory _addresses, uint256 _validUntilTime)
    virtual public;

  function attachAddress(uint256 _userId, address _address) virtual public;
  function attachManyAddresses(uint256[] memory _userIds, address[] memory _addresses)
    virtual public;

  function detachAddress(address _address) virtual public;
  function detachManyAddresses(address[] memory _addresses)
    virtual public;

  function detachSelf() virtual public;
  function detachSelfAddress(address _address) virtual public;
  function suspendUser(uint256 _userId) virtual public;
  function unsuspendUser(uint256 _userId) virtual public;
  function suspendManyUsers(uint256[] memory _userIds) virtual public;
  function unsuspendManyUsers(uint256[] memory _userIds) virtual public;
  function updateUser(uint256 _userId, uint256 _validUntil, bool _suspended)
    virtual public;

  function updateManyUsers(
    uint256[] memory _userIds,
    uint256 _validUntil,
    bool _suspended) virtual public;

  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    virtual public;

  function updateManyUsersExtended(
    uint256[] memory _userIds,
    uint256 _key,
    uint256 _value) virtual public;
}
