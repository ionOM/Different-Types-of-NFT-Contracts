// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MinionsERC721A is ERC721A, Ownable {

    //////////////////
    // Errors ////////
    //////////////////

    error MinionsERC721A__NotEnoughFunds();
    error MinionsERC721A__MintLimitPerUser();
    error MinionsERC721A__SupplyExceeded();
    error MinionsERC721A__RefundPeriodExpired();
    error MinionsERC721A__NotYourNft();
    error MinionsERC721A__NotPastRefundPeriod();

    /////////////////////
    // State Variables //
    /////////////////////

    uint256 public constant mintPrice = 1 ether;
    uint256 public constant maxMintSupply = 19;
    uint256 public constant maxMintPerUSer = 3;

    uint256 public constant refundPeriod = 1 minutes;
    uint256 public refundEndTimestamp;
    address public refundAddress;

    mapping(uint256 => uint256) public refundEndTimestamps;
    mapping(uint256 => bool) public hasRefunded;

    /////////////////
    // Functions ////
    /////////////////

    constructor() ERC721A("MinionsERC721A", "M721A") {
        refundAddress = address(this);
        refundEndTimestamp = block.timestamp + refundPeriod;
    }


    function withdraw(address _address) external onlyOwner {
        if (block.timestamp < refundEndTimestamp) revert MinionsERC721A__NotPastRefundPeriod();
        (bool success, ) = payable(_address).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function refund(uint256 tokenId) external {
        if (block.timestamp > getRefundDeadline(tokenId)) revert MinionsERC721A__RefundPeriodExpired();
        if (msg.sender != ownerOf(tokenId)) revert MinionsERC721A__NotYourNft();
        uint256 refundAmount = getRefundAmount(tokenId);
        // transfer ownership of NFT
        _transfer(msg.sender, refundAddress, tokenId);
        // mark refunded
        hasRefunded[tokenId] = true;
        //refund the Price
        Address.sendValue(payable(msg.sender), refundAmount);
        
    } 

    function safeMint(uint256 quantity) public payable {
        if (msg.value != (mintPrice * quantity)) revert MinionsERC721A__NotEnoughFunds();
        if ((_numberMinted(msg.sender) + quantity) > maxMintPerUSer) revert MinionsERC721A__MintLimitPerUser();
        if ((_totalMinted() + quantity) > maxMintSupply) revert MinionsERC721A__SupplyExceeded();

        _safeMint(msg.sender, quantity);

        refundEndTimestamp = block.timestamp + refundPeriod;
        for(uint256 i = _currentIndex - quantity; i < _currentIndex; i++) {
            refundEndTimestamps[i] = refundEndTimestamp;
        }
    }

    function getRefundDeadline(uint256 tokenId) public view returns(uint256) {
        if(hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndTimestamps[tokenId];
    }

    function getRefundAmount(uint256 tokenId) public view returns(uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
       return mintPrice;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmWhhHfxMZtpPbCkbMs61jVoAXF9dA7yMERMyXESd8CTaR";
    }
}