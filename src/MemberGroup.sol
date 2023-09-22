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

  EnumerableSet.AddressSet private _members;
  mapping(address member => uint score) private _scores;

  constructor(address admin, string memory _name) {
    _setupRole(DEFAULT_ADMIN_ROLE, admin);
    _setupRole(ADDER_ROLE, admin);
    _setupRole(REMOVER_ROLE, admin);
    _setupRole(UPDATER_ROLE, admin);

    name = _name;
  }

  function addMember(address member, uint score) public virtual onlyRole(ADDER_ROLE) {
    _members.add(member);
    _scores[member] = score;
  }

  function removeMember(address member) public virtual onlyRole(REMOVER_ROLE) {
    _members.remove(member);
    _scores[member] = 0;
  }

  function getScore(address member) public view returns (uint) {
    return _scores[member];
  }

  function setScore(address member, uint score) public virtual onlyRole(UPDATER_ROLE) {
    if (!_members.contains(member)) {
      revert("setScore/notMember");
    }
    _scores[member] = score;
  }

  function getMemberCount() public view returns (uint) {
    return _members.length();
  }

  function getMember(uint index) public view returns (address member, uint score) {
    member = _members.at(index);
    score = _scores[member];
  }

  function getMembers() public view returns (address[] memory members, uint[] memory scores) {
    uint memberCount = _members.length();
    members = new address[](memberCount);
    scores = new uint[](memberCount);
    for (uint i = 0; i < memberCount; i++) {
      members[i] = _members.at(i);
      scores[i] = _scores[members[i]];
    }
  }
}
