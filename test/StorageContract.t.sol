// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../contracts/StorageContract.sol";

contract StorageContractTest is Test {
    StorageContract public storageContract;
    
    // Test addresses
    address public constant OWNER = address(0x1);
    address public constant REGISTRY = address(0x2);
    address public constant ACCOUNT = address(0x3);
    
    // Test domain hashes
    bytes32 public constant PARENT_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae; // aastar.eth
    bytes32 public constant SUB_NODE = 0x3c2e632b9818fb2809a494170e5eb02960f9ef5ef40ac0d1d31359c57bd8323e; // sub.aastar.eth
    
    // Set up the test environment
    function setUp() public {
        storageContract = new StorageContract();
        vm.startPrank(OWNER);
    }
    
    // Test subdomain registration
    function testRegisterSubdomain() public {
        vm.expectEmit(true, true, true, true);
        emit StorageContract.SubdomainRegistered(REGISTRY, PARENT_NODE, SUB_NODE, OWNER);
        
        storageContract.registerSubdomain(REGISTRY, PARENT_NODE, SUB_NODE, OWNER);
        
        address owner = storageContract.registries(REGISTRY, SUB_NODE);
        assertEq(owner, OWNER);
    }
    
    // Test authorization check
    function testRegisterSubdomainUnauthorized() public {
        // Ensure ACCOUNT is not an admin
        vm.stopPrank();

        // Modify StorageContract to add admin check for registerSubdomain
        // First, make the original contract admin check for registerSubdomain
        vm.startPrank(OWNER);
        storageContract.removeAdmin(OWNER); // To ensure we reset state between tests
        storageContract.addAdmin(OWNER);
        vm.stopPrank();
        
        // Try with non-admin account
        vm.startPrank(ACCOUNT);
        
        vm.expectRevert("Not an admin");
        storageContract.registerSubdomain(REGISTRY, PARENT_NODE, SUB_NODE, OWNER);
        
        vm.stopPrank();
    }
    
    // Test setting resolved address
    function testSetResolvedAddress() public {
        vm.expectEmit(true, false, false, true);
        emit StorageContract.AddressSet(SUB_NODE, ACCOUNT);
        
        storageContract.setResolvedAddress(SUB_NODE, ACCOUNT);
        
        address resolvedAddress = storageContract.resolvedAddresses(SUB_NODE);
        assertEq(resolvedAddress, ACCOUNT);
    }
    
    // Test setting text record
    function testSetTextRecord() public {
        string memory key = "email";
        string memory value = "test@example.com";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.TextRecordSet(SUB_NODE, key, value);
        
        storageContract.setTextRecord(SUB_NODE, key, value);
        
        string memory storedValue = storageContract.textRecords(SUB_NODE, key);
        assertEq(storedValue, value);
    }
    
    // Test setting content hash
    function testSetContentHash() public {
        bytes memory hash = hex"1220c3c4733ec8affd06cf9e9ff50ffc6bcd2ec85a6170004bb709669c31de94391a";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.ContentHashSet(SUB_NODE, hash);
        
        storageContract.setContentHash(SUB_NODE, hash);
        
        bytes memory storedHash = storageContract.contentHashes(SUB_NODE);
        assertEq(storedHash, hash);
    }
    
    // Test setting avatar
    function testSetAvatar() public {
        string memory avatarUrl = "ipfs://QmUUzaZxNvMJg6UruLo5vVSjcpnT6GfiHNufdpFLfYEWQh";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.AvatarSet(SUB_NODE, avatarUrl);
        
        storageContract.setAvatar(SUB_NODE, avatarUrl);
        
        string memory storedUrl = storageContract.avatars(SUB_NODE);
        assertEq(storedUrl, avatarUrl);
    }
    
    // Test setting contract name
    function testSetContractName() public {
        string memory name = "TestContract";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.ContractNameSet(SUB_NODE, name);
        
        storageContract.setContractName(SUB_NODE, name);
        
        string memory storedName = storageContract.contractNames(SUB_NODE);
        assertEq(storedName, name);
    }
    
    // Test setting multi-chain address
    function testSetMultiChainAddress() public {
        uint256 chainId = 137; // Polygon
        bytes memory addr = hex"1234567890123456789012345678901234567890";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.MultiChainAddressSet(SUB_NODE, chainId, addr);
        
        storageContract.setMultiChainAddress(SUB_NODE, chainId, addr);
        
        bytes memory storedAddr = storageContract.multiChainAddresses(SUB_NODE, chainId);
        assertEq(storedAddr, addr);
    }
} 