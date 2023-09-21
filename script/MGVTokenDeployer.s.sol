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

    // Owner can mint
    uint balanceBefore = mgv.balanceOf(address(this));
    vm.prank(owner);
    mgv.mint(address(this), 1_000 ether);
    require(mgv.balanceOf(address(this)) == balanceBefore + 1_000 ether, "owner minting failed");

    // Non-owner cannot mint
    vm.expectRevert("ERC20PresetMinterPauser: must have minter role to mint");
    vm.prank(address(this));
    mgv.mint(address(this), 1_000 ether);
  }
}
