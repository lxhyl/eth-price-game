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
    AggregatorV3Interface ethUsdPriceFeed;

    uint256 public tokenId = 1;

    uint256 public currentEpoch = 1;

    bool public mustStake;
    uint256 public minStakeEthAmount = 1e15;
    mapping(uint256 => GameMeta) historyGame;

    GameMeta currentGame;
    event DistributeNftForWinner(uint256 epoch, address to, uint256 tokenId);
    event StartGame(uint256 epoch, uint256 startPrice);
    event Bet(uint256 epoch, address user, int256 upOrDown);
    event EndGame(uint256 epoch);

    // goliri ethusd feed 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    constructor(address feed) ERC721("gameBoy", "GB") {
        ethUsdPriceFeed = AggregatorV3Interface(feed);
    }

    // user functions
    function bet(int256 upOrDown) external {
        if (currentGame.startPrice == 0) revert("Game not start");
        if (block.timestamp > currentGame.startTime + 1 hours)
            revert("Can't join in-progress game");

        if (mustStake && msg.value < minStakeEthAmount)
            revert("eth not enough");

        if (upOrDown > 0) {
            if (currentGame.upGamer.length() > 100) revert("too much upGamer");
            currentGame.upGamer.add(msg.sender);
        } else {
            if (currentGame.downGamer.length() > 100)
                revert("too much downGamer");
            currentGame.downGamer.add(msg.sender);
        }
        emit Bet(currentEpoch, msg.sender, upOrDown);
    }

    function endCurrentGame() external {
        GameMeta storage game = currentGame;
        if (block.timestamp < game.startTime + 3 hours)
            revert("Can't end ongoing game");
        uint256 endPrice = geEthtLatestPrice();

        uint256 startPrice = game.startPrice;
        game.endPrice = endPrice;
        uint256 epoch = currentEpoch;
        EnumerableSet.AddressSet storage winners = endPrice >= startPrice
            ? game.upGamer
            : game.downGamer;
        for (uint256 i; i < winners.length(); i++) {
            uint256 _tokenId = tokenId;
            address winner = winners.at(i);
            super._mint(winner, tokenId);
            emit DistributeNftForWinner(epoch, winner, _tokenId);
            tokenId++;
        }

        historyGame[epoch] = game;
        currentEpoch = epoch + 1;

        emit EndGame(epoch);
    }

    // utils functions
    function geEthtLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        if (price <= 0) revert("chainLink feed error");
        return uint256(price);
    }

    function getGameByEpoch(uint256 epoch)
        public
        view
        returns (
            uint256 startPrice,
            uint256 endPrice,
            uint256 startTime,
            address[] memory upGamer,
            address[] memory downGamer
        )
    {
        GameMeta storage game;
        uint256 _currentEpoch = currentEpoch;
        if (epoch > _currentEpoch) revert("game not found");
        if (epoch < _currentEpoch) game = historyGame[epoch];
        game = currentGame;
        startPrice = game.startPrice;
        endPrice = game.endPrice;
        startTime = game.startTime;
        for (uint256 i; i < game.upGamer.length(); i++) {
            upGamer.push(game.upGamer.at(i));
        }
        for (uint256 i; i < game.downGamer.length(); i++) {
            downGamer.push(game.downGamer.at(i));
        }
    }

    // admin functions
    function start() external onlyOwner {
        if (currentGame.startPrice != 0) revert("Game alredy start");
        uint256 price = geEthtLatestPrice();
        currentGame.startPrice = price;
        currentGame.startTime = block.timestamp;
        emit StartGame(currentEpoch, price);
    }

    function setMustStake(bool stake) external onlyOwner {
        mustStake = stake;
    }

    function setMinStakeAmount(uint256 amount) external onlyOwner {
        minStakeEthAmount = amount;
    }
}
