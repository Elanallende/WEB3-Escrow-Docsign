// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MultiSignatureAgreement is Ownable, ReentrancyGuard, Pausable, AccessControl {
    using SafeMath for uint256;

    // Define the roles for access control
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    // Variables
    address public creator;
    string public agreementText;
    address[] public signers;
    uint public requiredSignatures;
    uint public currentSignatures;
    uint public agreementCreationTime;
    uint public signingDeadline;
    
    // Escrow-related variables
    uint public totalAmount;
    mapping(address => uint) public distribution;
    mapping(address => bool) public hasSigned;
    mapping(address => bool) public hasReceived;

    IERC20 public usdc;

    event AgreementSigned(address signer);
    event FundsDeposited(uint amount);
    event FundsReleased(address recipient, uint amount);
    event AgreementCanceled();
    event DistributionUpdated(address signer, uint percentage);

    modifier onlySigner() {
        require(hasRole(SIGNER_ROLE, msg.sender), "Only signer can perform this action");
        _;
    }

    modifier withinDeadline() {
        require(block.timestamp <= signingDeadline, "Signing period expired");
        _;
    }

    modifier agreementFullySigned() {
        require(currentSignatures >= requiredSignatures, "Agreement not fully signed");
        _;
    }

    constructor(address _usdc, uint _requiredSignatures, string memory _agreementText, uint _deadline) {
        creator = msg.sender;
        usdc = IERC20(_usdc);
        requiredSignatures = _requiredSignatures;
        agreementText = _agreementText;
        agreementCreationTime = block.timestamp;
        signingDeadline = _deadline;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Add signers to the agreement
    function addSigner(address signer) external onlyOwner {
        require(!hasRole(SIGNER_ROLE, signer), "Signer already added");
        signers.push(signer);
        _setupRole(SIGNER_ROLE, signer);
    }

    // Allow users to sign the agreement
    function signAgreement() external onlySigner withinDeadline {
        require(!hasSigned[msg.sender], "You already signed");
        hasSigned[msg.sender] = true;
        currentSignatures++;
        emit AgreementSigned(msg.sender);
    }

    // Check if agreement is fully signed
    function isAgreementSigned() public view returns (bool) {
        return currentSignatures >= requiredSignatures;
    }

    // Deposit USDC into the contract for escrow
    function deposit(uint amount) external onlyOwner whenNotPaused {
        require(amount > 0, "Deposit amount must be greater than zero");
        require(usdc.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        totalAmount = totalAmount.add(amount);
        emit FundsDeposited(amount);
    }

    // Set fractional distribution for signers
    function setDistribution(address signer, uint percentage) external onlyOwner {
        require(hasRole(SIGNER_ROLE, signer), "Not a signer");
        distribution[signer] = percentage;
        emit DistributionUpdated(signer, percentage);
    }

    // Release escrow funds to signers once agreement is fully signed
    function releaseFunds() external agreementFullySigned nonReentrant whenNotPaused {
        require(totalAmount > 0, "No funds available to release");
        require(!hasReceived[msg.sender], "Already received funds");

        uint amount = totalAmount.mul(distribution[msg.sender]).div(100);
        require(amount > 0, "No funds for distribution");

        hasReceived[msg.sender] = true;
        totalAmount = totalAmount.sub(amount);

        require(usdc.transfer(msg.sender, amount), "Transfer failed");
        emit FundsReleased(msg.sender, amount);
    }

    // Cancel agreement and refund USDC if not signed
    function cancelAgreement() external onlyOwner whenNotPaused {
        require(!isAgreementSigned(), "Agreement already signed");
        require(totalAmount > 0, "No funds to refund");
        
        uint refundAmount = totalAmount;
        totalAmount = 0;
        require(usdc.transfer(creator, refundAmount), "Refund failed");
        emit AgreementCanceled();
    }

    // Pause the contract in case of emergency
    function pause() external onlyOwner {
        _pause();
    }

    // Unpause the contract to resume functionality
    function unpause() external onlyOwner {
        _unpause();
    }

    // Add role-based access control for signer
    function grantSignerRole(address signer) external onlyOwner {
        _setupRole(SIGNER_ROLE, signer);
    }

    // Check the current agreement status
    function agreementStatus() external view returns (uint256 signatures, uint256 totalAmountInEscrow, bool isSigned) {
        return (currentSignatures, totalAmount, isAgreementSigned());
    }

    // Get distribution percentage for a signer
    function getSignerDistribution(address signer) external view returns (uint256) {
        return distribution[signer];
    }
}
