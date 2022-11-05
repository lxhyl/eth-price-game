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
        uint256 ethAmount;
        EnumerableSet.AddressSet upGamers;
        EnumerableSet.AddressSet downGamers;
    }
    AggregatorV3Interface ethUsdPriceFeed;

    uint256 public tokenId = 1;

    uint256 public currentEpoch = 1;

    bool public mustStake;
    uint256 public minStakeEthAmount = 1e15;
    mapping(uint256 => GameMeta) games;

    event MintNftForWinner(uint256 epoch, address to, uint256 tokenId);
    event StartGame(uint256 epoch, uint256 startPrice);
    event Bet(uint256 epoch, address user, int256 upOrDown);
    event EndGame(uint256 epoch);

    // goliri ethusd feed 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    constructor(address feed) ERC721("gameBoy", "GB") {
        ethUsdPriceFeed = AggregatorV3Interface(feed);
    }

    // user functions
    function bet(int256 upOrDown) external payable {
        uint256 epoch = currentEpoch;
        if (games[epoch].startPrice == 0) revert("Game not start");
        if (block.timestamp > games[epoch].startTime + 1 hours)
            revert("Can't join in-progress game");

        if (mustStake) {
            if (msg.value < minStakeEthAmount) revert("eth not enough");
            games[epoch].ethAmount += msg.value;
        }

        if (upOrDown > 0) {
            if (games[epoch].upGamers.length() > 100)
                revert("too much upGamer");
            games[epoch].upGamers.add(msg.sender);
        } else {
            if (games[epoch].downGamers.length() > 100)
                revert("too much downGamer");
            games[epoch].downGamers.add(msg.sender);
        }
        emit Bet(epoch, msg.sender, upOrDown);
    }

    function endCurrentGame() external {
        uint256 epoch = currentEpoch;
        if (block.timestamp < games[epoch].startTime + 3 hours)
            revert("Can't end ongoing game");
        uint256 endPrice = geEthtLatestPrice();
        uint256 startPrice = games[epoch].startPrice;
        games[epoch].endPrice = endPrice;

        EnumerableSet.AddressSet storage winners = endPrice >= startPrice
            ? games[epoch].upGamers
            : games[epoch].downGamers;
        for (uint256 i; i < winners.length(); i++) {
            uint256 _tokenId = tokenId;
            address winner = winners.at(i);
            super._mint(winner, tokenId);
            emit MintNftForWinner(epoch, winner, _tokenId);
            tokenId++;
        }
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
            uint256 ethAmount,
            address[] memory upGamers,
            address[] memory downGamers
        )
    {
        if (epoch > currentEpoch) revert("game not exist");
        GameMeta storage game = games[epoch];
        uint256 upGamersLen = game.upGamers.length();
        uint256 downGamersLen = game.downGamers.length();
        address[] memory upGamers = new address[](upGamersLen);
        address[] memory downGamers = new address[](downGamersLen);
        for (uint256 i; i < upGamersLen; i++) {
            upGamers[i] = game.upGamers.at(i);
        }
        for (uint256 i; i < downGamersLen; i++) {
            downGamers[i] = game.downGamers.at(i);
        }
        startPrice = game.startPrice;
        endPrice = game.endPrice;
        startTime = game.startTime;
        ethAmount = game.ethAmount;
    }

    // admin functions
    function start() external onlyOwner {
        uint256 epoch = currentEpoch;
        if (games[epoch].startPrice != 0) revert("Game alredy start");
        uint256 price = geEthtLatestPrice();
        games[epoch].startPrice = price;
        games[epoch].startTime = block.timestamp;
        emit StartGame(epoch, price);
    }

    function setMustStake(bool stake) external onlyOwner {
        mustStake = stake;
    }

    function setMinStakeAmount(uint256 amount) external onlyOwner {
        minStakeEthAmount = amount;
    }
}
