// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../contracts/ENSManager.sol";
import "../contracts/StorageContract.sol";
import "../contracts/ENSRegistry.sol";

contract ENSManagerTest is Test {
    ENSManager public ensManager;
    StorageContract public storageContract;
    ENSRegistry public ensRegistry;
    
    // Test addresses
    address public constant OWNER = address(0x1);
    address public constant ACCOUNT = address(0x3);
    address public constant RESOLVER = address(0x4);
    
    // Test domain names
    string public constant ROOT_DOMAIN = "eth";
    string public constant DOMAIN = "aastar";
    string public constant SUBDOMAIN = "sub";
    
    // Test domain hashes
    bytes32 public constant ETH_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
    bytes32 public constant PARENT_NODE = 0xaf44fcef9d64d9c7abe55a98111b80a2aa017cee3bacf637c12bb20374657eb4;
    bytes32 public constant SUB_NODE = 0x3c2e632b9818fb2809a494170e5eb02960f9ef5ef40ac0d1d31359c57bd8323e;
    
    // Set up the test environment
    function setUp() public {
        // Create and set up ENSRegistry
        ensRegistry = new ENSRegistry();
        
        // Create and set up StorageContract
        storageContract = new StorageContract();
        
        // Create ENSManager with ENSRegistry and StorageContract
        ensManager = new ENSManager(address(ensRegistry), address(storageContract));
        
        // Add owner as admin in storage contract
        vm.startPrank(OWNER);
        storageContract.addAdmin(address(ensManager));
        vm.stopPrank();
        
        // Set up domain ownership in ENSRegistry for testing
        vm.startPrank(address(ensManager));
        // Set up parent domain ownership to OWNER
        ensRegistry.setOwner(ETH_NODE, OWNER);
        ensRegistry.setOwner(PARENT_NODE, OWNER);
        vm.stopPrank();
    }
    
    // Test updating storage contract
    function testUpdateStorageContract() public {
        address newStorageContract = address(0x5);
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, false, false);
        emit ENSManager.StorageContractUpdated(newStorageContract);
        
        ensManager.updateStorageContract(newStorageContract);
        
        assertEq(address(ensManager.storageContract()), newStorageContract);
        
        vm.stopPrank();
    }
    
    // Test updating ENS registry
    function testUpdateENSRegistry() public {
        address newRegistry = address(0x6);
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, false, false);
        emit ENSManager.ENSRegistryUpdated(newRegistry);
        
        ensManager.updateENSRegistry(newRegistry);
        
        assertEq(address(ensManager.ensRegistry()), newRegistry);
        
        vm.stopPrank();
    }
    
    // Test registering subdomain
    function testRegisterSubdomain() public {
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, true);
        emit ENSManager.SubdomainRegistered(ROOT_DOMAIN, DOMAIN, SUBDOMAIN, ACCOUNT);
        
        ensManager.registerSubdomain(ROOT_DOMAIN, DOMAIN, SUBDOMAIN, ACCOUNT);
        
        assertEq(ensRegistry.owner(SUB_NODE), ACCOUNT);
        
        vm.stopPrank();
    }
    
    // Test setting resolver
    function testSetResolver() public {
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, false);
        emit ENSManager.ResolverSet(PARENT_NODE, RESOLVER);
        
        ensManager.setResolver(PARENT_NODE, RESOLVER);
        
        assertEq(ensRegistry.resolver(PARENT_NODE), RESOLVER);
        
        vm.stopPrank();
    }
    
    // Test setting text record
    function testSetTextRecord() public {
        string memory key = "email";
        string memory value = "test@example.com";
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, true);
        emit ENSManager.TextRecordSet(PARENT_NODE, key, value);
        
        ensManager.setTextRecord(PARENT_NODE, key, value);
        
        assertEq(storageContract.textRecords(PARENT_NODE, key), value);
        
        vm.stopPrank();
    }
    
    // Test setting content hash
    function testSetContentHash() public {
        bytes memory hash = hex"1220c3c4733ec8affd06cf9e9ff50ffc6bcd2ec85a6170004bb709669c31de94391a";
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, false);
        emit ENSManager.ContentHashSet(PARENT_NODE, hash);
        
        ensManager.setContentHash(PARENT_NODE, hash);
        
        assertEq(storageContract.contentHashes(PARENT_NODE), hash);
        
        vm.stopPrank();
    }
    
    // Test setting avatar
    function testSetAvatar() public {
        string memory avatarUrl = "ipfs://QmUUzaZxNvMJg6UruLo5vVSjcpnT6GfiHNufdpFLfYEWQh";
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, false);
        emit ENSManager.AvatarSet(PARENT_NODE, avatarUrl);
        
        ensManager.setAvatar(PARENT_NODE, avatarUrl);
        
        assertEq(storageContract.avatars(PARENT_NODE), avatarUrl);
        
        vm.stopPrank();
    }
    
    // Test setting contract name
    function testSetContractName() public {
        string memory name = "TestContract";
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, false);
        emit ENSManager.ContractNameSet(PARENT_NODE, name);
        
        ensManager.setContractName(PARENT_NODE, name);
        
        assertEq(storageContract.contractNames(PARENT_NODE), name);
        
        vm.stopPrank();
    }
    
    // Test setting multi-chain address
    function testSetMultiChainAddress() public {
        uint256 chainId = 137; // Polygon
        bytes memory addr = hex"1234567890123456789012345678901234567890";
        
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, true, true);
        emit ENSManager.MultiChainAddressSet(PARENT_NODE, chainId, addr);
        
        ensManager.setMultiChainAddress(PARENT_NODE, chainId, addr);
        
        assertEq(storageContract.multiChainAddresses(PARENT_NODE, chainId), addr);
        
        vm.stopPrank();
    }
} 