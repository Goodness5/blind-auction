// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    constructor() ERC721("superman", "SSG") {
        // address _name;
        _mint(msg.sender, 1);
    }
}