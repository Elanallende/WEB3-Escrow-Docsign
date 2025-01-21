<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MultiSignature Agreement DApp</title>
    <script src="https://cdn.jsdelivr.net/npm/web3/dist/web3.min.js"></script>
</head>
<body>
    <h1>MultiSignature Agreement DApp</h1>

    <!-- User's Wallet Info -->
    <button id="connectWallet">Connect Wallet</button>
    <p id="walletAddress"></p>

    <!-- Agreement Signing -->
    <div id="agreement">
        <h2>Agreement Details</h2>
        <p id="agreementText">Agreement: <span id="agreementTextSpan"></span></p>
        <button id="signAgreement" disabled>Sign Agreement</button>
    </div>

    <!-- Escrow Interaction -->
    <div id="escrow">
        <h2>Escrow Actions</h2>
        <input type="number" id="depositAmount" placeholder="Deposit Amount (USDC)">
        <button id="depositButton" disabled>Deposit</button>

        <h3>Set Distribution</h3>
        <input type="text" id="signerAddress" placeholder="Signer Address">
        <input type="number" id="distributionPercentage" placeholder="Distribution Percentage">
        <button id="setDistributionButton" disabled>Set Distribution</button>

        <button id="releaseFundsButton" disabled>Release Funds</button>
    </div>

    <script>
        const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");

        let contract;
        let userAccount;
        let contractAddress = "YOUR_CONTRACT_ADDRESS"; // Replace with deployed contract address
        let contractABI = [ /* Your contract ABI here */ ]; // Replace with actual ABI

        window.onload = () => {
            if (typeof window.ethereum !== 'undefined') {
                document.getElementById("connectWallet").addEventListener("click", connectWallet);
                document.getElementById("signAgreement").addEventListener("click", signAgreement);
                document.getElementById("depositButton").addEventListener("click", deposit);
                document.getElementById("setDistributionButton").addEventListener("click", setDistribution);
                document.getElementById("releaseFundsButton").addEventListener("click", releaseFunds);
            } else {
                alert("Please install MetaMask!");
            }
        };

        async function connectWallet() {
            try {
                const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
                userAccount = accounts[0];
                document.getElementById("walletAddress").innerText = `Connected: ${userAccount}`;

                // Initialize the contract instance
                contract = new web3.eth.Contract(contractABI, contractAddress);

                // Get and display agreement text
                const agreementText = await contract.methods.agreementText().call();
                document.getElementById("agreementTextSpan").innerText = agreementText;

                // Enable interaction buttons
                enableButtons();
            } catch (error) {
                console.error("Error connecting wallet:", error);
            }
        }

        async function signAgreement() {
            try {
                await contract.methods.signAgreement().send({ from: userAccount });
                alert("Agreement signed successfully!");
                document.getElementById("signAgreement").disabled = true;
            } catch (error) {
                console.error("Error signing agreement:", error);
            }
        }

        async function deposit() {
            try {
                const amount = document.getElementById("depositAmount").value;
                if (amount <= 0) return alert("Enter a valid amount to deposit");

                const usdcAddress = "USDC_CONTRACT_ADDRESS"; // Replace with USDC contract address
                const usdc = new web3.eth.Contract([
                    { "constant": true, "inputs": [], "name": "decimals", "outputs": [{ "name": "", "type": "uint8" }], "payable": false, "stateMutability": "view", "type": "function" },
                    { "constant": false, "inputs": [{ "name": "to", "type": "address" }, { "name": "amount", "type": "uint256" }], "name": "transferFrom", "outputs": [{ "name": "", "type": "bool" }], "payable": false, "stateMutability": "nonpayable", "type": "function" }
                ], usdcAddress);

                // Transfer USDC to the contract
                await usdc.methods.transferFrom(userAccount, contractAddress, web3.utils.toWei(amount)).send({ from: userAccount });
                alert("Deposit successful!");
            } catch (error) {
                console.error("Error depositing funds:", error);
            }
        }

        async function setDistribution() {
            try {
                const signer = document.getElementById("signerAddress").value;
                const percentage = document.getElementById("distributionPercentage").value;
                if (!web3.utils.isAddress(signer)) return alert("Invalid signer address");
                if (percentage <= 0 || percentage > 100) return alert("Invalid distribution percentage");

                await contract.methods.setDistribution(signer, percentage).send({ from: userAccount });
                alert("Distribution set successfully!");
            } catch (error) {
                console.error("Error setting distribution:", error);
            }
        }

        async function releaseFunds() {
            try {
                await contract.methods.releaseFunds().send({ from: userAccount });
                alert("Funds released successfully!");
            } catch (error) {
                console.error("Error releasing funds:", error);
            }
        }

        function enableButtons() {
            document.getElementById("signAgreement").disabled = false;
