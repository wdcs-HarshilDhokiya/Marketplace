// NFT_Marketplace

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract nftMarketplace is ERC721URIStorage{
  
    address payable Owner;

    constructor() ERC721("MyNFT", "MNFT") {
        Owner=payable(msg.sender);
    }

    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;

    uint256 listprice=1 ether;

    struct listedItems{
        uint tokenid;
        address payable owner;
        bool isListed;
    }

    struct marketDatas{
        address buyer;
        address seller;
    }

    mapping (uint=>listedItems) public listedItem;
    mapping (uint=>mapping(address=>uint)) public sellReq;
    mapping (uint=>marketDatas) public marketData;
    mapping (address=>mapping(uint=>bool)) public sellerFlag;
    mapping (address=>mapping(uint=>bool)) public buyerFlag;

    function updateListPrice(uint256 updatedPrice) public {
        require(msg.sender==Owner,"You are not an Owner");
        listprice=updatedPrice;
    }

    function getListprice() public view returns(uint256) {
        return listprice;
    }

    function getCurrentIdToListedItem() public view returns(listedItems memory) {
        uint currentId=tokenIds.current();
        return listedItem[currentId];
    } 

    function getTokenIdToListedItem(uint tokenId) public view returns(listedItems memory) {
        return listedItem[tokenId];
    }

    function getCurrentId() public view returns(uint256) {
        return tokenIds.current();
    }

    function newTokenList(string memory _uri) public payable  {
        require(msg.value==listprice,"You have to pay require listing price");
        
        payable(Owner).transfer(msg.value);
        uint tokenId=tokenIds.current();
        tokenIds.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uri);

        listedItem[tokenId]=listedItems(
            tokenId,
            payable(msg.sender),
            true
        );
    }

    function getAllTokens() public view returns(listedItems[] memory) {
        uint TokenCount;
        uint tokenIndex;

        for(uint i;i<tokenIds.current();i++){
            TokenCount+=1;
        }

        listedItems[] memory allTokens=new listedItems[](TokenCount);
        for(uint i;i<tokenIds.current();i++){
            allTokens[tokenIndex]=listedItem[i];
            tokenIndex+=1;
        }

        return allTokens; 
    } 

    function getMyTokens() public view returns(listedItems[] memory) {
        uint myTokenCount;
        uint tokenIndex;

        for(uint i;i<tokenIds.current();i++){
            if(listedItem[i].owner==msg.sender){
                myTokenCount+=1;
            }
        }

        listedItems[] memory myTokens=new listedItems[](myTokenCount);
        for(uint i;i<tokenIds.current();i++){
            if(listedItem[i].owner==msg.sender){
                myTokens[tokenIndex]=listedItem[i];
                tokenIndex+=1;
            }
        }
        return myTokens;
    }

    function sell(uint256 tokenId,uint price) public {
        require(ownerOf(tokenId)==msg.sender,"You are not an Owner");
        require(sellerFlag[msg.sender][tokenId]==false,"Token is alredy on sale");

        sellReq[tokenId][msg.sender]=price;
        sellerFlag[msg.sender][tokenId]=true;
        _transfer(msg.sender,address(this),tokenId);
        marketData[tokenId].seller=msg.sender;

        listedItem[tokenId]=listedItems(
            tokenId,
            payable(address(this)),
            true
        );
    }


    function buy(uint256 tokenId) public payable {
        require(msg.value==sellReq[tokenId][marketData[tokenId].seller],"You have to pay purchase price");
        require(sellerFlag[marketData[tokenId].seller][tokenId]==true,"This item is not in sale");

        _transfer(address(this),msg.sender,tokenId);
        marketData[tokenId].buyer=msg.sender;
        sellerFlag[msg.sender][tokenId]=false;
        payable(marketData[tokenId].seller).transfer(msg.value);  

        listedItem[tokenId]=listedItems(
            tokenId,
            payable(msg.sender),
            false
        );
    }
}