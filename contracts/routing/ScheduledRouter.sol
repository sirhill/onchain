pragma solidity ^0.8.0;


import "./BasicRouter.sol";


/**
 * @title ScheduledRouter
 * @dev ScheduledRouter is a proxy which redirect all incoming transactions
 *
 * SPDX-License-Identifier: MIT
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 *
 * Error messages
 * SR01: Invalid schedule
 */
contract ScheduledRouter is BasicRouter {

  struct Schedule {
    uint256 startAt;
    uint256 endAt;
  }

  mapping(address => Schedule) public schedules;

  event Scheduled(uint256 startAt, uint256 endAt);

  function schedule(address _origin) public view returns (uint256, uint256) {
    Schedule memory schedule_ = schedules[_origin];
    return (schedule_.startAt, schedule_.endAt);
  }

  function findDestination(address _origin) virtual override public view returns (address) {
    Schedule memory schedule_ = schedules[_origin];
    // solhint-disable-next-line not-rely-on-time
    if (block.timestamp < schedule_.startAt || block.timestamp > schedule_.endAt) {
      return address(0);
    }
    return super.findDestination(_origin);
  }

  function setRouteSchedule(address _origin, uint256 _startAt, uint256 _endAt)
    public onlyOwner configNotLocked returns (bool)
  {
    // solhint-disable-next-line not-rely-on-time
    require(_startAt > block.timestamp && _startAt < _endAt, "SR01");
    schedules[_origin] = Schedule(_startAt, _endAt);
    emit Scheduled(_startAt, _endAt);
    return true;
  }
}
