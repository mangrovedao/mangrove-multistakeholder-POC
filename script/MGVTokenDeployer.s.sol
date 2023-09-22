// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import {Deployer} from "script/lib/Deployer.sol";
import {MGVToken} from "src/MGVToken.sol";

contract MGVTokenDeployer is Deployer {
  MGVToken public mgv;

  function run() public {
    innerRun({owner: broadcaster(), initialSupply: 1_000_000_000 ether});
    outputDeployment();
  }

  function innerRun(address owner, uint initialSupply) public {
    broadcast();
    mgv = new MGVToken(owner, initialSupply);
    fork.set("TMGV", address(mgv));
    smokeTest(owner, initialSupply);
  }

  function smokeTest(address owner, uint initialSupply) internal {
    require(mgv.totalSupply() == initialSupply, "totalSupply does not match initialSupply");

    // Admin is admin
    require(mgv.hasRole(mgv.DEFAULT_ADMIN_ROLE(), owner), "admin is not admin");
  }
}
