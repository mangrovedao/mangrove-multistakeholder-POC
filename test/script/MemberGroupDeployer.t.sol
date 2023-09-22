// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MemberGroupDeployer} from "script/MemberGroupDeployer.s.sol";
import {MemberGroup} from "src/MemberGroup.sol";

contract MemberGroupDeployerTest is Test {
  MemberGroupDeployer _deployer;

  function setUp() public {
    _deployer = new MemberGroupDeployer();
  }

  function testSmokeTest() public {
    _deployer.innerRun({admin: address(this), name: "TestGroup"});
  }
}
