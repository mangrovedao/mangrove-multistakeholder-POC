// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import {Test, console2 as console} from "forge-std/Test.sol";
import {MGVToken} from "src/MGVToken.sol";

contract MGVTokenTest is Test {
  MGVToken _mgv;

  function setUp() public {
    _mgv = new MGVToken(address(this), 1_000_000_000 ether);
  }

  function testInitialSupply() public {
    assertEq(_mgv.totalSupply(), 1_000_000_000 ether);
    assertEq(_mgv.balanceOf(address(this)), 1_000_000_000 ether);
  }

  function testOwnerCanMint() public {
    uint balanceBefore = _mgv.balanceOf(address(this));
    console.log("address(this): %s", address(this));
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
