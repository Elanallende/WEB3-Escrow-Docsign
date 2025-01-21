# WEB3-Escrow-Docsign

Prerequisites:

   Web3.js: 

   Install it using npm or include it via a CDN.
      npm install web3

   Or, if you’re using a CDN:
      <script src="https://cdn.jsdelivr.net/npm/web3/dist/web3.min.js"></script>


This code represents a decentralized application (DApp) for a MultiSignature Agreement, which operates on a blockchain using Web3.js and Solidity. The DApp allows users to interact with a smart contract for agreement signing and escrow management. Here's an overview:

Frontend (HTML + JavaScript):
* User Interface (UI): It provides a simple interface to:
    * Connect a wallet (e.g., MetaMask).
    * Display wallet address once connected.
    * Show agreement details and allow users to sign it.
    * Deposit funds (USDC) into the smart contract escrow.
    * Set distribution percentages for funds among signers.
    * Release escrow funds once the agreement is signed by all required parties.
* JavaScript: The script interacts with a deployed smart contract, calling methods such as signing the agreement, depositing funds, setting distributions, and releasing funds. It uses the Web3.js library to connect with the Ethereum blockchain and interact with the contract.

Backend (Solidity Smart Contract):
* Smart Contract: Written in Solidity, it handles the logic for the MultiSignature Agreement, including:
    * Roles and Permissions: The contract uses AccessControl to assign roles, with specific permissions for signers and the owner.
    * Agreement Signing: Allows signers to sign the agreement and tracks the number of signatures.
    * Escrow: Supports depositing USDC into escrow, setting distribution percentages for signers, and releasing funds once all signatures are collected.
    * Contract Pausing: Allows the contract owner to pause or unpause the contract in case of emergencies.

Key Features:
* Multi-Signature Agreement: Multiple signers are required to sign the agreement before it becomes effective.
* Escrow Mechanism: Funds (in USDC) are held in escrow and can be distributed to signers based on predefined percentages after the agreement is fully signed.
* Role-Based Access Control: Only authorized users (signers and the owner) can perform certain actions like signing, depositing, and releasing funds.
This is a basic DApp for managing multi-party agreements with an integrated escrow system, leveraging blockchain for secure, transparent, and automated execution of contractual terms.
