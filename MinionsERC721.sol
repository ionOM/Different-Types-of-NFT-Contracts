// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/*
 * @title MinionsERC721
 * @author Ion Platon
 * @notice The ERC-721 introduces a standard for NFT, in other words, 
 * this type of Token is unique and can have different value than 
 * another Token from the same Smart Contract.
 */

contract MinionsERC721 is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;

    //////////////////
    // Errors ////////
    //////////////////
    error MinionsERC721__AllowListMintClosed();
    error MinionsERC721__PublicMintClosed();
    error MinionsERC721__NotOnTheAllowList();
    error MinionsERC721__NotEnoughFunds();
    error MinionsERC721__SoldOut();

    /////////////////////
    // State Variables //
    /////////////////////

    uint256 maxSupply public = 20; // Maximum total supply of tokens.
    uint256 maxSupplyForAllow public = 6; // Maximum supply for allow list minting.
    uint256 public nftPriceForAllowList = 0.001 ether; // Price for allow list minting.
    uint256 public nftPriceForPublic = 0.01 ether; // Price for public minting.
    bool public publicMintOpen = false; // Flag indicating if public minting is open.
    bool public allowListMintOpen = false; // Flag indicating if allow list minting is open.

    // Mapping to store addresses on the allow list.
    mapping(address => bool) public allowList;

    // Counter for token IDs.
    Counters.Counter private _tokenIdCounter;

    ///////////////////
    //// Modifiers ////
    //////////////////

    /**
     * @dev Modifier to check if allow list minting is open.
     */
    modifier isAllowListMintOpen() {
        if (!allowListMintOpen) {
            revert MinionsERC721__AllowListMintClosed();
        }
        _;
    }

    /**
     * @dev Modifier to check if the sender is on the allow list.
     */
    modifier isOnAllowList() {
        if (!allowList[msg.sender]) {
            revert MinionsERC721__NotOnTheAllowList();
        }
        _;
    }

    /**
     * @dev Modifier to check if the sent value matches the required value for the allow list.
     * @param requiredValue The required value to be sent.
     */
    modifier hasExactValueList(uint256 requiredValue) {
        if (msg.value != 0.001 ether) {
            revert MinionsERC721__NotEnoughFunds();
        }
        _;
    }

    /**
     * @dev Modifier to check if the allow list minting is not sold out.
     */
    modifier isNotSoldOutForAllow() {
        if (totalSupply() >= maxSupplyForAllow) {
            revert MinionsERC721__SoldOut();
        }
        _;
    }

    /**
     * @dev Modifier to check if public minting is open.
     */
    modifier isPublicMintOpen() {
        if (!publicMintOpen) {
            revert MinionsERC721__PublicMintClosed();
        }
        _;
    }

    /**
     * @dev Modifier to check if the sent value matches the required value for public minting.
     * @param requiredValue The required value to be sent.
     */
    modifier hasExactValuePublic(uint256 requiredValue) {
        if (msg.value != 0.01 ether) {
            revert MinionsERC721__NotEnoughFunds();
        }
        _;
    }

    /**
     * @dev Modifier to check if public minting is not sold out.
     */
    modifier isNotSoldOut() {
        if (totalSupply() >= maxSupply) {
            revert MinionsERC721__SoldOut();
        }
        _;
    }

    /////////////////
    // Functions ////
    /////////////////

    constructor() ERC721("MinionsERC721", "M721") {}

    /**
    * @dev Allows the owner to edit the minting windows for public and allow list minting.
    * @param _publicMintOpen Whether public minting should be open or closed.
    * @param _allowListMintOpen Whether allow list minting should be open or closed.
    */
    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner whenNotPaused {
       publicMintOpen = _publicMintOpen;
       allowListMintOpen = _allowListMintOpen; 
    }

    /**
    * @dev Sets addresses on the allowList mapping. Only callable by the owner.
    * @param addresses An array of addresses to be added to the allow list.
    */
    function setAllowList(address[] calldata addresses) external onlyOwner whenNotPaused {
        for( uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    /**
    * @dev Allows the owner to withdraw funds from the contract. Only callable by the owner.
    * @param _address The address to which the funds will be transferred.
    */
    function withdraw(address _address) external onlyOwner whenNotPaused {
        (bool success, ) = payable(_address).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }


    /**
    * @dev Pauses the contract, preventing further actions. Only callable by the owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
    * @dev Unpauses the contract, allowing further actions. Only callable by the owner.
    */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
    * @dev Mints an NFT for the sender if certain conditions are met, including allowance on the allowList mapping,
    * correct value sent, and availability within the allowed supply limit for allow list minting.
    */
    function allowListMint() public payable
     whenNotPaused
     isAllowListMintOpen 
     isOnAllowList 
     hasExactValueList(nftPriceForAllowList) 
     isNotSoldOutForAllow {
    
        internalMint();
    }

    /**
    * @dev Mints an NFT for the sender if certain conditions are met, including public minting being open,
    * correct value sent, and availability within the allowed supply limit for public minting.
    */
    function publicMint() public payable 
    whenNotPaused 
    isPublicMintOpen 
    hasExactValuePublic(0.01 ether) 
    isNotSoldOut {

        internalMint();

    }

    /**
    * @dev Internal function to mint an NFT for the sender.
    */
    function internalMint() internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmUju6fiSzbAue8ZMdjEzkDZXhbsUuu9wqHNhQq5vXNeXr/";
    }


    // The following functions are overrides required by Solidity.

    /**
    * @dev Overrides the token transfer function to add custom behavior before token transfers.
    * @param from The address from which tokens are transferred.
    * @param to The address to which tokens are transferred.
    * @param tokenId The ID of the token being transferred.
    * @param batchSize The number of tokens being transferred in a batch.
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
    * @dev Overrides the `supportsInterface` function to include support for multiple interfaces.
    * @param interfaceId The interface identifier.
    * @return True if the contract supports the given interface, false otherwise.
    */

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
