// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/core.sol";

contract CoreTest is Test {
    Core core;

    function setUp() public {
        core = new Core();
    }

    function testGeEthtLatestPrice() public {
        console.log(uint256(core.geEthtLatestPrice()));
    }
}
