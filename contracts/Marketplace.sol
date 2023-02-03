// Marketplace

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Marketplace is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    constructor() ERC1155("") {}

    struct collectionDetails{
        address creator;
        string name;
        uint items; 
    }

    struct tokenDatas{
        uint totalAmount;
        address[] buyer;
        address[] seller;
        uint floorPrice;
        bool nftFlag;
        bool isListed;
        mapping (address=>mapping(uint=>uint)) buyOrder;
        mapping (address=>mapping(uint=>uint)) sellOrder;
        mapping (uint=>address) idOwner;
    }

    mapping (string=>collectionDetails) public collectionDetail;
    mapping (string=>mapping(uint=>tokenDatas)) public tokenData; 
   
    function creatCollection(string memory collectionName) public {
        collectionDetail[collectionName].creator=msg.sender;
        collectionDetail[collectionName].name=collectionName;
    }

    function listItem(string memory collectionName,uint256 id,uint price, uint amount) public {
        require(msg.sender==tokenData[collectionName][id].idOwner[id],"you are not owner");
        require(tokenData[collectionName][id].isListed==false);             
        tokenData[collectionName][id].isListed=true;
        tokenData[collectionName][id].floorPrice=price;
        tokenData[collectionName][id].sellOrder[msg.sender][price]=amount;
    }

    function purchase(string memory collectionName,uint256 id,uint price, uint amount) public {
        
    }

    function creatItem(string memory collectionName, uint256 id, uint256 amount) 
        public 
        onlyOwner
    {
        require(amount>=1,"amount must be greater then zero");
        require(tokenData[collectionName][id].nftFlag==false,"This is NFT so you can't mint it again.");
        if(amount==1){
            tokenData[collectionName][id].nftFlag=true;
        }
        tokenData[collectionName][id].idOwner[id]=msg.sender;
        collectionDetail[collectionName].items+=1;
        tokenData[collectionName][id].totalAmount+=amount;
        // bytes memory data="0x00";
        _mint(msg.sender, id, amount, "");
    }

    function delistItem(string memory collectionName,uint256 id,uint price) public{
        require(msg.sender==tokenData[collectionName][id].idOwner[id],"you are not owner");
        require(tokenData[collectionName][id].isListed==true);
        tokenData[collectionName][id].isListed=false;
        tokenData[collectionName][id].floorPrice=price;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // function mint(address account, uint256 id, uint256 amount, bytes memory data)
    //     public
    //     onlyOwner
    // {
    //     _mint(account, id, amount, data);
    // }

    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //     public
    //     onlyOwner
    // {
    //     _mintBatch(to, ids, amounts, data);
    // }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}