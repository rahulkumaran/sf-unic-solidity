// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ApeTokenGuard {
    error MinimumApeNotMet();
    modifier apeGuard(uint minimumApe) {
        uint256 amount = IERC20(address(0x4d224452801ACEd8B2F0aebE155379bb5D594381)).balanceOf(msg.sender);
        if (amount < minimumApe) {
            revert MinimumApeNotMet();
        }
        _;
    }
}