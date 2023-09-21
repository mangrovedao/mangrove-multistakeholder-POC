// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MGVTokenDeployer} from "script/MGVTokenDeployer.s.sol";
import {MGVToken} from "src/MGVToken.sol";

contract MGVTokenDeployerTest is Test {
  MGVTokenDeployer _deployer;
  MGVToken _mgv;

  function setUp() public {
    _deployer = new MGVTokenDeployer();
    _deployer.innerRun({owner: address(this), initialSupply: 1_000_000_000 ether});
    _mgv = _deployer.mgv();
  }

  function testInitialSupply() public {
    assertEq(_mgv.totalSupply(), 1_000_000_000 ether);
  }

  function testOwnerCanMint() public {
    uint balanceBefore = _mgv.balanceOf(address(this));
    _mgv.mint(address(this), 1_000 ether);
    assertEq(_mgv.balanceOf(address(this)), balanceBefore + 1_000 ether);
  }

  function testNonOwnerCannotMint(address account) public {
    vm.assume(account != address(this));
    vm.expectRevert("ERC20PresetMinterPauser: must have minter role to mint");
    vm.prank(account);
    _mgv.mint(account, 1_000 ether);
  }
}
