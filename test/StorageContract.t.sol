// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../contracts/StorageContract.sol";

contract StorageContractTest is Test {
    StorageContract public storageContract;
    
    // Test addresses
    address public constant OWNER = address(0x1);
    address public constant ADMIN = address(0x2);
    address public constant USER = address(0x3);
    
    // Test domains
    bytes32 public constant DOMAIN_NODE = 0xaf44fcef9d64d9c7abe55a98111b80a2aa017cee3bacf637c12bb20374657eb4;
    
    // Set up the test environment
    function setUp() public {
        vm.startPrank(OWNER);
        storageContract = new StorageContract();
        storageContract.addAdmin(ADMIN);
        vm.stopPrank();
    }
    
    // Test adding an admin
    function testAddAdmin() public {
        vm.startPrank(OWNER);
        
        address newAdmin = address(0x4);
        
        vm.expectEmit(true, true, false, false);
        emit StorageContract.AdminAdded(newAdmin);
        
        storageContract.addAdmin(newAdmin);
        
        assertTrue(storageContract.admins(newAdmin));
        
        vm.stopPrank();
    }
    
    // Test removing an admin
    function testRemoveAdmin() public {
        vm.startPrank(OWNER);
        
        vm.expectEmit(true, true, false, false);
        emit StorageContract.AdminRemoved(ADMIN);
        
        storageContract.removeAdmin(ADMIN);
        
        assertFalse(storageContract.admins(ADMIN));
        
        vm.stopPrank();
    }
    
    // Test that non-owner cannot add an admin
    function testAddAdminNotOwner() public {
        vm.startPrank(USER);
        
        address newAdmin = address(0x4);
        
        vm.expectRevert();
        storageContract.addAdmin(newAdmin);
        
        vm.stopPrank();
    }
    
    // Test that non-owner cannot remove an admin
    function testRemoveAdminNotOwner() public {
        vm.startPrank(USER);
        
        vm.expectRevert();
        storageContract.removeAdmin(ADMIN);
        
        vm.stopPrank();
    }
    
    // Test registering a subdomain
    function testRegisterSubdomain() public {
        vm.startPrank(ADMIN);
        
        address registry = address(0x5);
        address owner = address(0x6);
        
        vm.expectEmit(true, true, true, true);
        emit StorageContract.SubdomainRegistered(registry, DOMAIN_NODE, owner);
        
        storageContract.registerSubdomain(registry, DOMAIN_NODE, owner);
        
        assertEq(storageContract.registries(registry, DOMAIN_NODE), owner);
        
        vm.stopPrank();
    }
    
    // Test that non-admin cannot register a subdomain
    function testRegisterSubdomainNotAdmin() public {
        vm.startPrank(USER);
        
        address registry = address(0x5);
        address owner = address(0x6);
        
        vm.expectRevert("Not authorized");
        storageContract.registerSubdomain(registry, DOMAIN_NODE, owner);
        
        vm.stopPrank();
    }
    
    // Test setting a resolved address
    function testSetResolvedAddress() public {
        vm.startPrank(ADMIN);
        
        address resolvedAddress = address(0x7);
        
        vm.expectEmit(true, true, true, false);
        emit StorageContract.ResolvedAddressSet(DOMAIN_NODE, resolvedAddress);
        
        storageContract.setResolvedAddress(DOMAIN_NODE, resolvedAddress);
        
        assertEq(storageContract.resolvedAddresses(DOMAIN_NODE), resolvedAddress);
        
        vm.stopPrank();
    }
    
    // Test setting a text record
    function testSetTextRecord() public {
        vm.startPrank(ADMIN);
        
        string memory key = "email";
        string memory value = "test@example.com";
        
        vm.expectEmit(true, true, true, true);
        emit StorageContract.TextRecordSet(DOMAIN_NODE, key, value);
        
        storageContract.setTextRecord(DOMAIN_NODE, key, value);
        
        assertEq(storageContract.textRecords(DOMAIN_NODE, key), value);
        
        vm.stopPrank();
    }
    
    // Test setting a content hash
    function testSetContentHash() public {
        vm.startPrank(ADMIN);
        
        bytes memory hash = hex"1220c3c4733ec8affd06cf9e9ff50ffc6bcd2ec85a6170004bb709669c31de94391a";
        
        vm.expectEmit(true, true, true, false);
        emit StorageContract.ContentHashSet(DOMAIN_NODE, hash);
        
        storageContract.setContentHash(DOMAIN_NODE, hash);
        
        assertEq(storageContract.contentHashes(DOMAIN_NODE), hash);
        
        vm.stopPrank();
    }
    
    // Test setting an avatar
    function testSetAvatar() public {
        vm.startPrank(ADMIN);
        
        string memory avatarUrl = "ipfs://QmUUzaZxNvMJg6UruLo5vVSjcpnT6GfiHNufdpFLfYEWQh";
        
        vm.expectEmit(true, true, true, false);
        emit StorageContract.AvatarSet(DOMAIN_NODE, avatarUrl);
        
        storageContract.setAvatar(DOMAIN_NODE, avatarUrl);
        
        assertEq(storageContract.avatars(DOMAIN_NODE), avatarUrl);
        
        vm.stopPrank();
    }
    
    // Test setting a contract name
    function testSetContractName() public {
        vm.startPrank(ADMIN);
        
        string memory name = "TestContract";
        
        vm.expectEmit(true, true, true, false);
        emit StorageContract.ContractNameSet(DOMAIN_NODE, name);
        
        storageContract.setContractName(DOMAIN_NODE, name);
        
        assertEq(storageContract.contractNames(DOMAIN_NODE), name);
        
        vm.stopPrank();
    }
    
    // Test setting a multi-chain address
    function testSetMultiChainAddress() public {
        vm.startPrank(ADMIN);
        
        uint256 chainId = 137; // Polygon
        bytes memory addr = hex"1234567890123456789012345678901234567890";
        
        vm.expectEmit(true, true, true, true);
        emit StorageContract.MultiChainAddressSet(DOMAIN_NODE, chainId, addr);
        
        storageContract.setMultiChainAddress(DOMAIN_NODE, chainId, addr);
        
        assertEq(storageContract.multiChainAddresses(DOMAIN_NODE, chainId), addr);
        
        vm.stopPrank();
    }
} 