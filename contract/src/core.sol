// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/AggregatorV3Interface.sol";

contract Core is ERC721, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct GameMeta {
        uint256 startPrice;
        uint256 endPrice;
        uint256 startTime;
        EnumerableSet.AddressSet upGamer;
        EnumerableSet.AddressSet downGamer;
    }
    AggregatorV3Interface ethUsdPriceFeed =
        AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);

    uint256 tokenId = 1;

    uint256 currentEpoch = 1;

    mapping(uint256 => GameMeta) historyGame;

    GameMeta currentGame;
    event DistributeNftForWinner(uint256 epoch, address to, uint256 tokenId);
    event StartGame(uint256 epoch, uint256 startPrice);
    event Bet(uint256 epoch, address user);
    event EndGame(uint256 epoch);

    constructor() ERC721("gameBoy", "GB") {}

    // user functions
    function bet(int256 upOrDown) external {
        if (currentGame.startPrice == 0) revert("Game not start");
        if (block.timestamp > currentGame.startTime + 1 hours)
            revert("Can't join in-progress game");
        if (upOrDown > 0) {
            if (currentGame.upGamer.length() > 100) revert("too much upGamer");
            currentGame.upGamer.add(msg.sender);
        } else {
            if (currentGame.downGamer.length() > 100)
                revert("too much downGamer");
            currentGame.downGamer.add(msg.sender);
        }
    }

    function endCurrentGame() external {
        if (block.timestamp < currentGame.startTime + 3 hours)
            revert("Can't end ongoing game");
        uint256 endPrice = geEthtLatestPrice();
        uint256 startPrice = currentGame.startPrice;
        currentGame.endPrice = endPrice;

        EnumerableSet.AddressSet storage winners = endPrice >= startPrice
            ? currentGame.upGamer
            : currentGame.downGamer;
        for (uint256 i; i < winners.length(); i++) {
            uint256 _tokenId = tokenId;
            address winner = winners.at(i);
            super._mint(winner, tokenId);
            emit DistributeNftForWinner(currentEpoch, winner, _tokenId);
            tokenId++;
        }
        currentEpoch++;
    }

    // admin functions
    function start() external onlyOwner {
        if (currentGame.startPrice != 0) revert("Game alredy start");
        currentGame.startPrice = geEthtLatestPrice();
        currentGame.startTime = block.timestamp;
    }

    // utils functions
    function geEthtLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        if (price <= 0) revert("chainLink feed error");
        return uint256(price);
    }
}
