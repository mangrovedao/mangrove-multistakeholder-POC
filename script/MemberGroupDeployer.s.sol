// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import {Deployer} from "script/lib/Deployer.sol";
import {MemberGroup} from "src/MemberGroup.sol";

contract MemberGroupDeployer is Deployer {
  MemberGroup public group;

  function run() public {
    innerRun({admin: broadcaster(), name: vm.envString("NAME")});
    outputDeployment();
  }

  function innerRun(address admin, string memory name) public {
    broadcast();
    group = new MemberGroup(admin, name);
    fork.set(name, address(group));
    smokeTest(admin, name);
  }

  function smokeTest(address admin, string memory name) internal view {
    require(keccak256(abi.encodePacked(group.name())) == keccak256(abi.encodePacked(name)), "name does not match specified name");

    // Admin is admin
    require(group.hasRole(group.DEFAULT_ADMIN_ROLE(), admin), "admin is not admin");
  }
}
