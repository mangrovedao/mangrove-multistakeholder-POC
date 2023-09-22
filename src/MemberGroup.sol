// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import "openzeppelin/access/AccessControlEnumerable.sol";

// Simple on-chain member group where members have a score that determines their voting power
contract MemberGroup is AccessControlEnumerable {
  // FIXME: move to allow reuse
  bytes32 public constant ADDER_ROLE = keccak256("ADDER_ROLE");
  bytes32 public constant REMOVER_ROLE = keccak256("REMOVER_ROLE");
  bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
  
  using EnumerableSet for EnumerableSet.AddressSet;

  string public name;
  uint public totalScore;

  EnumerableSet.AddressSet private _members;
  mapping(address member => uint score) private _scores;

  constructor(address admin, string memory _name) {
    _setupRole(DEFAULT_ADMIN_ROLE, admin);
    _setupRole(ADDER_ROLE, admin);
    _setupRole(REMOVER_ROLE, admin);
    _setupRole(UPDATER_ROLE, admin);

    name = _name;
  }

  function addMember(address member, uint score) external virtual onlyRole(ADDER_ROLE) {
    _members.add(member);
    _setScore(member, score);
  }

  function removeMember(address member) external virtual onlyRole(REMOVER_ROLE) {
    _setScore(member, 0);
    _members.remove(member);
  }

  function getScore(address member) external view returns (uint) {
    return _scores[member];
  }

  function getNormalizedScore(address member, uint scale) external view returns (uint) {
    if (totalScore == 0) {
      return 0;
    }
    return _scores[member] * scale / totalScore;
  }

  // NB: Reverts if totalScore overflows
  function setScore(address member, uint score) external virtual onlyRole(UPDATER_ROLE) {
    _setScore(member, score);
  }

  function _setScore(address member, uint score) internal {
    if (!_members.contains(member)) {
      revert("setScore/notMember");
    }
    totalScore -= _scores[member];
    _scores[member] = score;
    totalScore += score;
  }

  function getMemberCount() external view returns (uint) {
    return _members.length();
  }

  function getMember(uint index) external view returns (address member, uint score) {
    member = _members.at(index);
    score = _scores[member];
  }

  function getMembers() external view returns (address[] memory members, uint[] memory scores) {
    uint memberCount = _members.length();
    members = new address[](memberCount);
    scores = new uint[](memberCount);
    for (uint i = 0; i < memberCount; i++) {
      members[i] = _members.at(i);
      scores[i] = _scores[members[i]];
    }
  }
}
