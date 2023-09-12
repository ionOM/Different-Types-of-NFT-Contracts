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

    uint256 public constant mintPrice = 0.001 ether; // The price, in ether, to mint an NFT.
    uint256 public constant maxMintSupply = 19; // The maximum total supply of NFTs that can be minted.
    uint256 public constant maxMintPerUSer = 3; // The maximum number of NFTs a user can mint.

    uint256 public constant refundPeriod = 1 minutes; //The duration of the refund period.
    uint256 public refundEndTimestamp; // The timestamp when the refund period ends.
    address public refundAddress; // The address where refunds are collected.

    // Mapping to track refund end timestamps for each NFT token
    mapping(uint256 => uint256) public refundEndTimestamps;
    // Mapping to track whether a specific NFT token has been refunded
    mapping(uint256 => bool) public hasRefunded;

    /////////////////
    // Functions ////
    /////////////////

    /**
     * @dev Constructor initializes the contract and sets initial refundAddress and refundEndTimestamp.
     */
    constructor() ERC721A("MinionsERC721A", "M721A") {
        refundAddress = address(this);
        refundEndTimestamp = block.timestamp + refundPeriod;
    }

    /**
     * @dev Allows the owner to withdraw funds from the contract. Only callable after the refund period has expired.
     * @param _address The address to which the funds will be transferred.
     */
    function withdraw(address _address) external onlyOwner {
        if (block.timestamp < refundEndTimestamp) revert MinionsERC721A__NotPastRefundPeriod();
        (bool success, ) = payable(_address).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev Allows a user to request a refund for a specific NFT if within the refund period and they are the owner.
     * Transfers ownership of the NFT to the refundAddress and refunds the mintPrice to the user.
     * @param tokenId The ID of the NFT to be refunded.
     */
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

    /**
     * @dev Allows a user to mint a specified quantity of NFTs, provided they send the correct value and do not exceed limits.
     * @param quantity The quantity of NFTs to mint.
     */
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

    /**
     * @dev Gets the refund deadline for a specific tokenId.
     * @param tokenId The ID of the NFT.
     * @return The refund deadline timestamp.
     */
    function getRefundDeadline(uint256 tokenId) public view returns(uint256) {
        if(hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndTimestamps[tokenId];
    }

    /**
     * @dev Gets the refund amount for a specific tokenId.
     * @param tokenId The ID of the NFT.
     * @return The refund amount.
     */
    function getRefundAmount(uint256 tokenId) public view returns(uint256) {
        if (hasRefunded[tokenId]) {
            return 0;
        }
       return mintPrice;
    }

    /**
     * @dev Return the base URI for token metadata.
     * @return The base URI.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmWhhHfxMZtpPbCkbMs61jVoAXF9dA7yMERMyXESd8CTaR";
    }
}
