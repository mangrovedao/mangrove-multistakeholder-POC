// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/presets/ERC20PresetMinterPauser.sol";

// Simple ERC20 token with 18 decimals and preset minter and pauser roles
contract MGVToken is ERC20PresetMinterPauser {
  constructor(address owner, uint initialSupply) ERC20PresetMinterPauser("Test MGV", "TMGV") {
    _mint(owner, initialSupply);
    address msgSender = _msgSender();
    if (owner != _msgSender() && owner != address(0)) {
      _grantRole(DEFAULT_ADMIN_ROLE, owner);
      _grantRole(MINTER_ROLE, owner);
      _grantRole(PAUSER_ROLE, owner);
      _revokeRole(DEFAULT_ADMIN_ROLE, msgSender);
      _revokeRole(MINTER_ROLE, msgSender);
      _revokeRole(PAUSER_ROLE, msgSender);
    }
  }
}
