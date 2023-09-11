// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/*
 * @title MinionsERC1155
 * @author Ion Platon
 */


contract MinionsERC1155 is ERC1155, Ownable, Pausable, ERC1155Supply, PaymentSplitter {

    //////////////////
    // Errors ////////
    //////////////////

    error MinionsERC1155__PublicMintClosed();
    error MinionsERC1155__NotEnoughFunds();
    error MinionsERC1155__SupplyExceeded();
    error MinionsERC1155__AllowListMintClosed();
    error MinionsERC1155__NotOnTheAllowList();
    error MinionsERC1155__WalletLimitReached();
    error MinionsERC1155__WrongNFT();

    /////////////////////
    // State Variables //
    /////////////////////

    uint256 public priceForPublic = 0.01 ether; // Price for public minting.
    uint256 public priceForAllowList = 0.001 ether; // Price for allow list minting.
    uint256 public maxSupply = 20000; // Maximum total supply of tokens.
    uint256 public maxSupplyForAllow = 30; // Maximum supply for allow list minting.
    uint256 public maxPerWallet = 20; // Maximum allowed mints per wallet.
    bool public publicMintOpen = false; // Flag indicating if public minting is open.
    bool public allowListMintOpen = false; // Flag indicating if allow list minting is open.


    // Mapping to store addresses on the allow list.
    mapping(address => bool) public allowList;
    // Mapping to track purchases per wallet.
    mapping(address => uint256) public purchasesPerWallet;

    ///////////////////
    //// Modifiers ////
    //////////////////

   /**
    * @dev Modifier to check if public minting is open.
    */
    modifier isPublicMintOpen() {
        if (!publicMintOpen) {
            revert MinionsERC1155__PublicMintClosed();
        }
        _;
    }

    /**
    * @dev Modifier to check if the sent value matches the required value for public minting.
    * @param _amount The amount of NFTs to be minted.
    */
    modifier hasExactValuePublic(uint256 _amount) {
        if (msg.value != (priceForPublic * _amount)) {
            revert MinionsERC1155__NotEnoughFunds();
        }
        _;
    }

    /**
    * @dev Modifier to check if the total supply after minting won't exceed the maximum supply.
    * @param _id The ID of the NFT to be minted.
    * @param _amount The amount of NFTs to be minted.
    */
    modifier isNotSupplyExceeded(uint256 _id, uint256 _amount) {
        if ((totalSupply(_id) + _amount) > maxSupply) {
            revert MinionsERC1155__SupplyExceeded();
        }
        _;
    }

    /**
    * @dev Modifier to check if allow list minting is open.
    */
    modifier isAllowListMintOpen() {
        if (!allowListMintOpen) {
            revert MinionsERC1155__AllowListMintClosed();
        }
        _;
    }

    /**
    * @dev Modifier to check if the sender is on the allow list.
    */
    modifier isOnAllowList() {
        if (!allowList[msg.sender]) {
            revert MinionsERC1155__NotOnTheAllowList();
        }
        _;
    }

    /**
    * @dev Modifier to check if the sent value matches the required value for allow list minting.
    * @param _amount The amount of NFTs to be minted.
    */
    modifier hasExactValueAllow(uint256 _amount) {
         if (msg.value != (priceForAllowList * _amount)) {
            revert MinionsERC1155__NotEnoughFunds(); 
        }
        _;
    }

    /**
    * @dev Modifier to check if the total supply for allow list minting won't exceed the maximum supply.
    * @param _id The ID of the NFT to be minted.
    * @param _amount The amount of NFTs to be minted.
    */
    modifier isNotExceedingSupplyForAllow (uint256 _id, uint256 _amount) {
        if ((totalSupply(_id) + _amount) > maxSupplyForAllow) {
            revert MinionsERC1155__SupplyExceeded();
        }
        _;
    }

    /**
    * @dev Modifier to check if the wallet limit won't be exceeded.
    * @param _amount The amount of NFTs to be minted.
    */
    modifier isNotExceedingWalletLimit(uint256 _amount) {
        if (purchasesPerWallet[msg.sender] > (_amount + maxPerWallet)) {
            revert MinionsERC1155__WalletLimitReached();
        }
        _;
    }

    /**
    * @dev Modifier to check if the chosen NFT ID is within the allowed range.
    * @param _id The ID of the NFT to be minted.
    */
    modifier isCorrectNFT(uint256 _id) {
        if (_id >= 20) {
            revert MinionsERC1155__WrongNFT();
        }
        _;
    }

    /////////////////
    // Functions ////
    /////////////////

    /**
     * @dev Constructor for MinionsERC1155 contract.
     * @param _payees Array of addresses to receive payments from contract.
     * @param _shares Array of corresponding shares for each payee.
     */
    constructor(address[] memory _payees, uint256[] memory _shares)
        ERC1155("ipfs://QmWhhHfxMZtpPbCkbMs61jVoAXF9dA7yMERMyXESd8CTaR")
        PaymentSplitter(_payees, _shares)
    {}

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
    * @param _addresses An array of addresses to be added to the allow list.
    */
    function setAllowList(address[] calldata _addresses) external onlyOwner whenNotPaused {
        for( uint256 i = 0; i < _addresses.length; i++) {
            allowList[_addresses[i]] = true;
        }
    }

    /**
     * @dev Set new URI for token metadata.
     * @param newuri New URI to be set.
     */
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /**
     * @dev Pause the contract, preventing further actions.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the contract, allowing further actions.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Mint NFTs for the public based on ID and amount.
     * @param _id The ID of the NFT to be minted.
     * @param _amount The amount of NFTs to be minted.
     */
    function publicMint(uint256 _id, uint256 _amount)
        public
        payable
        whenNotPaused
        isPublicMintOpen
        hasExactValuePublic(_amount)
        isNotSupplyExceeded(_id, _amount)
        {

        mint(_id, _amount);
    }

    /**
     * @dev Mint NFTs for the allow list based on ID and amount.
     * @param _id The ID of the NFT to be minted.
     * @param _amount The amount of NFTs to be minted.
     */
    function allowListMint(uint256 _id, uint256 _amount) 
        public 
        payable
        whenNotPaused
        isAllowListMintOpen()
        isOnAllowList()
        hasExactValueAllow(_amount)
        isNotExceedingSupplyForAllow (_id, _amount)
        {
    
        mint(_id, _amount);

    }

    /**
     * @dev Mint multiple tokens in a batch.
     * @param to The address to which tokens will be minted.
     * @param ids Array of token IDs to mint.
     * @param amounts Array of token amounts to mint.
     * @param data Additional data to include in the mint.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Internal function to mint NFTs based on ID and amount.
     * @param _id The ID of the NFT to be minted.
     * @param _amount The amount of NFTs to be minted.
     */
    function mint(uint256 _id, uint256 _amount) 
        internal
        isNotExceedingWalletLimit(_amount)
        isCorrectNFT(_id)
        {
        
        _mint(msg.sender, _id, _amount, "");
        purchasesPerWallet[msg.sender] += _amount;
    }

    /**
     * @dev Overrides the beforeTokenTransfer function to add custom behavior before token transfers.
     * @param operator The address of the operator initiating the transfer.
     * @param from The address from which tokens are transferred.
     * @param to The address to which tokens are transferred.
     * @param ids Array of token IDs being transferred.
     * @param amounts Array of token amounts being transferred.
     * @param data Additional data included in the transfer.
     */
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Get the URI of a specific token ID.
     * @param _id The ID of the token.
     * @return The URI of the token.
     */
    function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }
}