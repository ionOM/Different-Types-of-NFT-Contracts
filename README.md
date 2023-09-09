# #Different-Types-of-NFT-Contracts

# 1) MinionsERC721 - ERC-721 Smart Contract

MinionsERC721 is an Ethereum-based smart contract that allows you to create and manage a collection of unique non-fungible tokens (NFTs). These NFTs can represent digital assets such as art, collectibles, or any unique items you want to tokenize.

This is the contract published on the testnet network sepolia: 0x54B358b429801f32dfd5c450562e0d391825D12d

## Features

- **Public Minting:** Users can mint NFTs by sending the required ether. Public minting can be controlled by the contract owner.

- **Allow List Minting:** Users on the allow list can mint NFTs at a specific price. Allow list minting can also be controlled by the contract owner.

- **Ownership Control:** The contract owner has full control over minting, pausing, and setting the allow list.

- **Flexible Pricing:** The contract supports different prices for public minting and allow list minting.

- **Batch Minting:** The contract owner can mint multiple NFTs at once for distribution.

- **Metadata Management:** The contract allows you to set or update metadata for each token.

- **Pausing:** The contract owner can pause and unpause contract actions for added security.

## Usage

You can deploy this contract to create your own NFT collection with the specified features. Users can then interact with the contract to mint NFTs based on the contract's rules.

## Requirements

- Solidity ^0.8.19
- OpenZeppelin smart contract library

## License

This smart contract is open-source and available under the MIT License. You are free to use, modify, and distribute it according to the terms of the license.

## Get Started

To get started with MinionsERC721, follow these steps:

1. Deploy the contract to the Ethereum blockchain.

2. Set the appropriate pricing and rules for public and allow list minting.

3. Add addresses to the allow list if you want to allow specific users to mint NFTs.

4. Start minting NFTs and create a unique collection on the Ethereum blockchain!

Feel free to customize and extend this contract to fit your specific use case.

Happy minting!

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

# 2) # MinionsERC1155: ERC-1155 Smart Contract

**MinionsERC1155** is a powerful Ethereum smart contract designed to streamline the creation and management of non-fungible tokens (NFTs) in compliance with the ERC-1155 standard. This contract offers a wide range of features that empower both developers and users, making it easier than ever to mint and manage NFTs.

## Key Features

### 1. Public Minting
- **Overview**: Public minting allows anyone to mint NFTs by simply sending Ether to the contract at a predefined price per token.
- **Use Case**: Ideal for open NFT sales, auctions, or any scenario where users can participate without prior authorization.
  
### 2. Allow List Minting
- **Overview**: Allow list minting is designed for exclusive access. Authorized addresses on the allow list can mint NFTs at a different price, offering a sense of exclusivity.
- **Use Case**: Perfect for rewarding loyal users, collaborators, or VIPs with unique NFTs.

### 3. Flexible Configuration
- **Overview**: The contract owner has the flexibility to customize various parameters, including prices, maximum supplies, and other minting constraints.
- **Use Case**: Tailor the contract to your specific project requirements and adapt to changing market conditions.

### 4. Pausing Capability
- **Overview**: The contract can be temporarily paused by the owner, preventing any further actions. This feature provides a safety net in case of emergencies or unforeseen circumstances.
- **Use Case**: Use it to address critical issues, perform maintenance, or handle unexpected events.

### 5. Payment Splitter
- **Overview**: The contract incorporates the PaymentSplitter from OpenZeppelin, making it easy to distribute revenue among multiple payees in a straightforward and automated manner.
- **Use Case**: Ideal for sharing proceeds among creators, collaborators, or stakeholders.

### 6. Batch Minting
- **Overview**: Save time and gas costs by minting multiple tokens in a single transaction using the batch minting functionality.
- **Use Case**: Efficiently mint sets of NFTs, such as collectible series, all at once.

## How to Use

### Public Minting
1. Users can mint NFTs by calling the `publicMint` function, specifying the desired token ID and quantity.
2. To complete the minting process, users must send Ether to the contract, matching the specified price for each token.

### Allow List Minting
1. Authorized addresses on the allow list can mint NFTs by invoking the `allowListMint` function.
2. To qualify for allow list minting, users must be on the allow list and send Ether equal to the allow list price.

### Owner Empowerment
- The contract owner enjoys full control and can execute various administrative actions:
  - Set the URI for token metadata.
  - Pause or unpause the contract to control contract actions.
  - Configure minting windows, opening or closing public and allow list minting.
  - Define the allow list by adding authorized addresses.
  - Perform batch minting to efficiently create multiple tokens at once.

## Prerequisites

To work with MinionsERC1155, you need the following:

- Solidity 0.8.19 or compatible version.
- OpenZeppelin Contracts library for Ethereum smart contracts.

## Getting Started

1. Clone the MinionsERC1155 repository.
2. Compile the contract using the Solidity compiler.
3. Deploy the contract on the Ethereum blockchain, specifying the constructor parameters as needed.

## License

MinionsERC1155 is open-source software, licensed under the MIT License.

