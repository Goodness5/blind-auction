// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract Auction {
    address public owner;

    struct Auction {
        uint128 startBlock;
        uint128 endBlock;
        address auctionCreator;
        address auctionedItem;
        address highestBidder;
        uint highestBid;
        uint itemID;
        bool started;
    }
    uint id;
    mapping(uint => Auction) public auctionID;
    mapping(address => mapping(uint => uint)) public userBidAMount;

    error invalidBlock();
    error notStarted();

    constructor() {
        owner = msg.sender;
    }

    function createAuction(
        uint128 _startBlock,
        uint128 _endBlock,
        address _auctionItem,
        uint256 _nftID
    ) external {
        require(_auctionItem != address(0));

        if (_endBlock <= _startBlock) revert invalidBlock();
        Auction storage auction = auctionID[id];
        auction.startBlock = _startBlock;
        auction.endBlock = _endBlock;
        auction.auctionCreator = msg.sender;
        auction.auctionedItem = _auctionItem;
        auction.started = true;
        auction.itemID = _nftID;
        IERC721(_auctionItem).transferFrom(msg.sender, address(this), _nftID);
        id++;
    }

    function bid(uint256 _auctionID) external payable {
        require(msg.value != 0, "empty value");
        require(msg.sender != owner, "Ole");

        Auction storage auction = auctionID[_auctionID];
        if (auction.started) revert notStarted();
        require(msg.sender != auction.auctionCreator);
        userBidAMount[msg.sender][_auctionID] = msg.value;
        if (msg.value > auction.highestBid) {
            auction.highestBid = msg.value;
            auction.highestBidder = msg.sender;
        }
    }

    function updatebBid(uint _id) public payable {
        Auction storage auction = auctionID[_id];
        uint previous_bid = userBidAMount[msg.sender][_id];

        if (auction.started) revert notStarted();
        if (previous_bid != 0) {
            userBidAMount[msg.sender][_id] += msg.value;
        }
        
         else {
            revert("you've not placed a bid");
        }
        uint current_bid = userBidAMount[msg.sender][_id];
        if (current_bid > auction.highestBid) {
            auction.highestBidder = msg.sender;
            auction.highestBid = current_bid;
        }
    }

     function withdraw(uint256 _auctionid) public {
        Auction storage aunction = auctionID[_auctionid];
        require(userBidAMount[msg.sender][_auctionid] > 0, "You don't have a bid.");

        uint amount = (userBidAMount[msg.sender][_auctionid] * 9) / 10;

        if (msg.sender != address(0)) {
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Transfer failed.");
            userBidAMount[msg.sender][_auctionid] = 0;
        } else {
            revert("invalid caller");
        }
        // updatebBid(_auctionid);
    }

       function withdrawNft(uint256 _auctionId, address _to) public {
          Auction storage aunction = auctionID[_auctionId];

        IERC721 prize = IERC721(aunction.auctionedItem);
        require(!aunction.started, "Auction is still ongoing.");
        require(prize.ownerOf(aunction.itemID) == address(this), "nft not present");
        prize.safeTransferFrom(address(this), _to, aunction.itemID);
    }

    function isOwner() internal view {
        require(msg.sender == owner);
    }
}
