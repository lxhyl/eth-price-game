// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/core.sol";

contract CoreTest is Test {
    Core core;

    function setUp() public {
        core = new Core(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    function testGeEthtLatestPrice() public {
        console.log(core.geEthtLatestPrice());
    }

    function testFlow() public {
        core.start();
        core.bet(1);
        (
            uint256 price,
            ,
            ,
            ,
            address[] memory upGamers,
            address[] memory downGamers
        ) = core.getGameByEpoch(1);
        console.log(price);
        console.log(upGamers[0]);
    }
}
