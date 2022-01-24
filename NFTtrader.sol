// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFTtrader {
    mapping(address => mapping(uint256 => Listing)) public Listings;
    mapping(address => uint256) public balances;

    struct Listing {
        uint256 price;
        address seller;
    }

    function addListing(uint256 price, address contractaddr, uint256 TokenID) public {
        ERC1155 token = ERC1155(contractaddr);
        require(token.balanceOf(msg.sender, TokenID) > 0, "caller must own given token");
        require(token.isApprovedForAll(msg.sender, address(this)), "contract must be approved");
        Listings[contractaddr][TokenID] = Listing(price, msg.sender);
    }

    function purchase(address contractaddr, uint256 TokenID, uint256 amount) public payable {
        Listing memory item = Listings[contractaddr][TokenID];
        require(msg.value >= item.price*amount, "insufficient funds sent");
        balances[item.seller] += msg.value;

        ERC1155 token = ERC1155(contractaddr);
        token.safeTransferFrom(item.seller, msg.sender, TokenID, amount, "");
    }

    function withdraw(uint256 amount, address payable destaddr) public {
        require(amount <= balances[msg.sender], "insufficient funds");
        destaddr.transfer(amount);
        balances[msg.sender] -= amount;
    }


}
