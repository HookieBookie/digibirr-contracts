// SPDX-License-Identifier: MIT
// File: openzeppelin-solidity/contracts/crowdsale/validation/IndividuallyCappedCrowdsale.sol
pragma solidity >=0.4.23;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Crowdsale.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @title IndividuallyCappedCrowdsale
 * @dev Crowdsale with per-user caps.
 */
abstract contract IndividuallyCappedCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) public contributions;
  mapping(address => uint256) public caps;

  /**
   * @dev Sets a specific user's maximum contribution.
   * @param _beneficiary Address to be capped
   * @param _cap Wei limit for individual contribution
   */
  function setUserCap(address _beneficiary, uint256 _cap) external onlyOwner {
    caps[_beneficiary] = _cap;
  }

  /**
   * @dev Returns the cap of a specific user.
   * @param _beneficiary Address whose cap is to be checked
   * @return Current cap for individual user
   */
  function getUserCap(address _beneficiary) public view returns (uint256) {
    return caps[_beneficiary];
  }

  /**
   * @dev Returns the amount contributed so far by a sepecific user.
   * @param _beneficiary Address of contributor
   * @return User contribution so far
   */
  function getUserContribution(address _beneficiary)
    public view returns (uint256)
  {
    return contributions[_beneficiary];
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the user's funding cap.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal virtual override
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(contributions[_beneficiary].add(_weiAmount) <= caps[_beneficiary]);
  }

  /**
   * @dev Extend parent behavior to update user contributions
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal virtual override
  {
    super._updatePurchasingState(_beneficiary, _weiAmount);
    contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
  }

}