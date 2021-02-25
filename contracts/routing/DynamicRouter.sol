pragma solidity ^0.8.0;

import "./ScheduledRouter.sol";


/**
 * @title DynamicRouter
 * @dev DynamicRouter
 *
 * @notice To avoid abuse the configuration need to be locked before the redirection is active
 *
 * SPDX-License-Identifier: MIT
 * @author Cyril Lapinte - <cyril.lapinte@gmail.com>
 *
 * Error messages
 * DR01: maxBalances and weights length must match destinations length
 */
contract DynamicRouter is ScheduledRouter {

  struct Distribution {
    uint256[] maxBalances;
    uint256[] weights;
  }

  mapping(address => Distribution) private _distributions;

  event DistributionDefined(uint256[] maxBalances, uint256[] weights);

  function maxBalances(address _origin) public view returns (uint256[] memory) {
    return _distributions[_origin].maxBalances;
  }

  function weights(address _origin) public view returns (uint256[] memory) {
    return _distributions[_origin].weights;
  }

  function findDestination(address _origin) override public view returns (address) {
    Distribution memory distribution = _distributions[_origin];
    Route memory route = routes[_origin];

    address selectedDestination = address(0);
    uint256 minWeightedBalance = ~uint256(0);
    for (uint256 i=0; i < route.destinations.length; i++) {
      address destination = route.destinations[i];

      if (destination.balance == 0) {
        selectedDestination = destination;
        break;
      }

      if (destination.balance < distribution.maxBalances[i]) {
        uint256 weight =
          (distribution.weights[i] > 0) ? distribution.weights[i] : 1;
        uint256 weightedBalance = destination.balance / weight;
        if (weightedBalance < minWeightedBalance) {
          minWeightedBalance = weightedBalance;
          selectedDestination = destination;
        }
      }
    }
    
    return selectedDestination;
  }

  function setDistribution(
    address _origin,
    uint256[] memory _maxBalances,
    uint256[] memory _weights)
    public onlyOwner configNotLocked returns (bool)
  {
    require(_maxBalances.length == routes[_origin].destinations.length
      && _weights.length == routes[_origin].destinations.length, "DR01");
    
    _distributions[_origin] = Distribution(_maxBalances, _weights);
    emit DistributionDefined(_maxBalances, _weights);

    return true;
  }
}
