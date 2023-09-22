// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import {Test, console2 as console} from "forge-std/Test.sol";
import {MemberGroup} from "src/MemberGroup.sol";

contract MemberGroupTest is Test {
  // FIXME: move to allow reuse
  bytes32 public constant ADDER_ROLE = keccak256("ADDER_ROLE");
  bytes32 public constant REMOVER_ROLE = keccak256("REMOVER_ROLE");
  bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
  
  MemberGroup _group;

  function setUp() public {
    _group = new MemberGroup(address(this), "Test Group");
  }

  function testNoInitialMembers() public {
    assertEq(_group.getMemberCount(), 0);
    vm.expectRevert();
    _group.getMember(0);
    (address[] memory members, uint[] memory scores) = _group.getMembers();
    assertEq(members.length, 0);
    assertEq(scores.length, 0);
  }

  // # addMember tests

  function testAddMemberWithoutAdderRoleReverts(address caller, address member, uint score) public {
    vm.assume(caller != address(this));
    _group.grantRole(REMOVER_ROLE, caller);
    _group.grantRole(UPDATER_ROLE, caller);
    vm.expectRevert();
    vm.prank(caller);
    _group.addMember(member, score);
  }

  function testAddMember(address member, uint score) public {
    _group.addMember(member, score);

    assertEq(_group.getMemberCount(), 1);

    (address _member, uint _score) = _group.getMember(0);
    assertEq(_member, member);
    assertEq(_score, score);

    assertEq(_group.getScore(member), score);
    assertEq(_group.totalScore(), score);

    (address[] memory members, uint[] memory scores) = _group.getMembers();
    assertEq(members.length, 1);
    assertEq(scores.length, 1);
    assertEq(members[0], member);
    assertEq(scores[0], score);
  }

  function testAddMemberTwice(address member, uint score) public {
    uint score2 = score < type(uint).max ? score + 1 : score - 1;

    _group.addMember(member, score);
    assertEq(_group.getScore(member), score);
    assertEq(_group.totalScore(), score);

    _group.addMember(member, score2);
    assertEq(_group.getMemberCount(), 1);

    assertEq(_group.getScore(member), score2);
    assertEq(_group.totalScore(), score2);

    (address _member, uint _score) = _group.getMember(0);
    assertEq(_member, member);
    assertEq(_score, score2);
  }

  function testAddTwoMembers(address member1, address member2, uint score1, uint score2) public {
    vm.assume(member1 != member2);
    vm.assume(score1 < type(uint).max/2);
    vm.assume(score2 < type(uint).max/2);

    _group.addMember(member1, score1);
    _group.addMember(member2, score2);

    assertEq(_group.getMemberCount(), 2);

    (address _member1, uint _score1) = _group.getMember(0);
    (address _member2, uint _score2) = _group.getMember(1);
    assertEq(_member1, member1);
    assertEq(_score1, score1);
    assertEq(_member2, member2);
    assertEq(_score2, score2);

    assertEq(_group.getScore(member1), score1);
    assertEq(_group.getScore(member2), score2);
    assertEq(_group.totalScore(), score1 + score2);

    (address[] memory members, uint[] memory scores) = _group.getMembers();
    assertEq(members.length, 2);
    assertEq(scores.length, 2);
    assertEq(members[0], member1);
    assertEq(scores[0], score1);
    assertEq(members[1], member2);
    assertEq(scores[1], score2);
  }

  // # removeMember tests

  function testRemoveMemberWithoutRemoverRoleReverts(address caller, address member, uint score) public {
    vm.assume(caller != address(this));
    _group.grantRole(ADDER_ROLE, caller);
    _group.grantRole(UPDATER_ROLE, caller);
    _group.addMember(member, score);
    vm.expectRevert();
    vm.prank(caller);
    _group.removeMember(member);
  }

  function testRemoveMember(address member, uint score) public {
    _group.addMember(member, score);
    _group.removeMember(member);

    assertEq(_group.getMemberCount(), 0);

    vm.expectRevert();
    _group.getMember(0);

    assertEq(_group.getScore(member), 0);
    assertEq(_group.totalScore(), 0);

    (address[] memory members, uint[] memory scores) = _group.getMembers();
    assertEq(members.length, 0);
    assertEq(scores.length, 0);
  }

  function testRemoveNonMember(address member, uint score) public {
    vm.assume(member != address(this));
    _group.addMember(member, score);
    vm.expectRevert();
    _group.removeMember(address(this));
    assertEq(_group.getMemberCount(), 1);
    assertEq(_group.getScore(member), score);
    assertEq(_group.totalScore(), score);
  }

  // # setScore tests

  function testSetScoreWithoutUpdaterRoleReverts(address caller, address member, uint score) public {
    vm.assume(caller != address(this));
    _group.grantRole(ADDER_ROLE, caller);
    _group.grantRole(REMOVER_ROLE, caller);
    _group.addMember(member, score);
    vm.expectRevert();
    vm.prank(caller);
    _group.setScore(member, score);
  }

  function testSetScoreOfNonMemberReverts(address member, uint score) public {
    vm.expectRevert();
    _group.setScore(member, score);
  }

  function testSetScore(address member, uint score, uint score2) public {
    _group.addMember(member, score);
    _group.setScore(member, score2);
    assertEq(_group.getScore(member), score2);
    assertEq(_group.totalScore(), score2);
    (address _member, uint _score) = _group.getMember(0);
    assertEq(_member, member);
    assertEq(_score, score2);
  }

  // # getNormalizedScore tests

  function testGetNormalizedScoreMultipleMembers(address member1, address member2, uint score1, uint score2, uint scale) public {
    vm.assume(member1 != member2);
    vm.assume(score1 < type(uint).max >> 128);
    vm.assume(score2 < type(uint).max >> 128);
    vm.assume(scale < type(uint).max >> 128);

    _group.addMember(member1, score1);
    _group.addMember(member2, score2);

    assertEq(_group.getNormalizedScore(member1, scale), score1 + score2 == 0 ? 0 : scale * score1 / (score1 + score2));
  }
}
