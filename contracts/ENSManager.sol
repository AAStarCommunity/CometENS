// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ENS} from "ens-contracts/contracts/registry/ENS.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./StorageContract.sol";

/**
 * @title ENSManager
 * @dev Manage ENS domain registration and resolution settings
 */
contract ENSManager is Ownable {
    // Storage contract
    StorageContract public storageContract;
    
    // ENS registry
    ENS public ensRegistry;
    
    // Gateway verifier interface
    address public gatewayVerifier;
    
    // Events
    event StorageContractUpdated(address indexed storageContract);
    event ENSRegistryUpdated(address indexed ensRegistry);
    event GatewayVerifierUpdated(address indexed gatewayVerifier);
    event SubdomainRegistered(bytes32 indexed parentNode, string indexed label, address indexed owner);
    
    /**
     * @dev Constructor
     * @param _ensRegistry ENS registry address
     * @param _storageContract Storage contract address
     */
    constructor(address _ensRegistry, address _storageContract) Ownable(msg.sender) {
        ensRegistry = ENS(_ensRegistry);
        storageContract = StorageContract(_storageContract);
    }
    
    /**
     * @dev Update storage contract address
     * @param _storageContract New storage contract address
     */
    function setStorageContract(address _storageContract) external onlyOwner {
        require(_storageContract != address(0), "Invalid storage contract address");
        storageContract = StorageContract(_storageContract);
        emit StorageContractUpdated(_storageContract);
    }
    
    /**
     * @dev Update ENS registry address
     * @param _ensRegistry New ENS registry address
     */
    function setENSRegistry(address _ensRegistry) external onlyOwner {
        require(_ensRegistry != address(0), "Invalid ENS registry address");
        ensRegistry = ENS(_ensRegistry);
        emit ENSRegistryUpdated(_ensRegistry);
    }
    
    /**
     * @dev Set Gateway verifier address
     * @param _gatewayVerifier New Gateway verifier address
     */
    function setGatewayVerifier(address _gatewayVerifier) external onlyOwner {
        gatewayVerifier = _gatewayVerifier;
        emit GatewayVerifierUpdated(_gatewayVerifier);
    }
    
    /**
     * @dev Register a subdomain
     * @param parentNode Parent domain namehash
     * @param label Subdomain label
     * @param owner Owner address
     */
    function registerSubdomain(bytes32 parentNode, string calldata label, address owner) external {
        // Ensure sender has permission to set subdomains under parent domain
        address parentOwner = ensRegistry.owner(parentNode);
        require(parentOwner == msg.sender, "Not authorized for parent domain");
        
        // Calculate subdomain namehash
        bytes32 labelHash = keccak256(bytes(label));
        bytes32 subnode = keccak256(abi.encodePacked(parentNode, labelHash));
        
        // Set subdomain owner in ENS registry
        ensRegistry.setSubnodeOwner(parentNode, labelHash, owner);
        
        // Register subdomain in storage contract
        storageContract.registerSubdomain(address(ensRegistry), parentNode, subnode, owner);
        
        emit SubdomainRegistered(parentNode, label, owner);
    }
    
    /**
     * @dev Set domain resolved address
     * @param node Domain namehash
     * @param addr Resolved address
     */
    function setAddr(bytes32 node, address addr) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Set resolved address in storage contract
        storageContract.setResolvedAddress(node, addr);
    }
    
    /**
     * @dev Set text record
     * @param node Domain namehash
     * @param key Record key
     * @param value Record value
     */
    function setText(bytes32 node, string calldata key, string calldata value) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Set text record in storage contract
        storageContract.setTextRecord(node, key, value);
    }
    
    /**
     * @dev Set content hash
     * @param node Domain namehash
     * @param hash Content hash
     */
    function setContentHash(bytes32 node, bytes calldata hash) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Set content hash in storage contract
        storageContract.setContentHash(node, hash);
    }
    
    /**
     * @dev Set avatar
     * @param node Domain namehash
     * @param avatarUrl Avatar URL
     */
    function setAvatar(bytes32 node, string calldata avatarUrl) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Set avatar in storage contract
        storageContract.setAvatar(node, avatarUrl);
    }
    
    /**
     * @dev Set contract name
     * @param node Domain namehash
     * @param name Contract name
     */
    function setContractName(bytes32 node, string calldata name) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Set contract name in storage contract
        storageContract.setContractName(node, name);
    }
    
    /**
     * @dev Set multi-chain address
     * @param node Domain namehash
     * @param chainId Chain ID
     * @param addr Address bytes
     */
    function setMultiChainAddress(bytes32 node, uint256 chainId, bytes calldata addr) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Set multi-chain address in storage contract
        storageContract.setMultiChainAddress(node, chainId, addr);
    }
    
    /**
     * @dev Batch set text records
     * @param node Domain namehash
     * @param keys Record keys array
     * @param values Record values array
     */
    function batchSetTextRecords(bytes32 node, string[] calldata keys, string[] calldata values) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Batch set text records in storage contract
        storageContract.batchSetTextRecords(node, keys, values);
    }
    
    /**
     * @dev Batch set multi-chain addresses
     * @param node Domain namehash
     * @param chainIds Chain IDs array
     * @param addrs Address bytes array
     */
    function batchSetMultiChainAddresses(bytes32 node, uint256[] calldata chainIds, bytes[] calldata addrs) external {
        // Ensure sender has permission to set domain
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // Batch set multi-chain addresses in storage contract
        storageContract.batchSetMultiChainAddresses(node, chainIds, addrs);
    }
} 