// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../contracts/StorageContract.sol";

contract StorageContractTest is Test {
    StorageContract public storageContract;
    
    // 测试用地址
    address public constant OWNER = address(0x1);
    address public constant REGISTRY = address(0x2);
    address public constant ACCOUNT = address(0x3);
    
    // 测试域名哈希
    bytes32 public constant PARENT_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae; // aastar.eth
    bytes32 public constant SUB_NODE = 0x3c2e632b9818fb2809a494170e5eb02960f9ef5ef40ac0d1d31359c57bd8323e; // sub.aastar.eth
    
    // 设置测试环境
    function setUp() public {
        storageContract = new StorageContract();
        vm.startPrank(OWNER);
    }
    
    // 测试注册子域名
    function testRegisterSubdomain() public {
        vm.expectEmit(true, true, true, true);
        emit StorageContract.SubdomainRegistered(REGISTRY, PARENT_NODE, SUB_NODE, OWNER);
        
        storageContract.registerSubdomain(REGISTRY, PARENT_NODE, SUB_NODE, OWNER);
        
        address owner = storageContract.registries(REGISTRY, SUB_NODE);
        assertEq(owner, OWNER);
    }
    
    // 测试授权检查
    function testRegisterSubdomainUnauthorized() public {
        vm.stopPrank();
        vm.startPrank(ACCOUNT);
        
        vm.expectRevert("Not authorized");
        storageContract.registerSubdomain(REGISTRY, PARENT_NODE, SUB_NODE, OWNER);
    }
    
    // 测试设置解析地址
    function testSetResolvedAddress() public {
        vm.expectEmit(true, false, false, true);
        emit StorageContract.AddressSet(SUB_NODE, ACCOUNT);
        
        storageContract.setResolvedAddress(SUB_NODE, ACCOUNT);
        
        address resolvedAddress = storageContract.resolvedAddresses(SUB_NODE);
        assertEq(resolvedAddress, ACCOUNT);
    }
    
    // 测试设置文本记录
    function testSetTextRecord() public {
        string memory key = "email";
        string memory value = "test@example.com";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.TextRecordSet(SUB_NODE, key, value);
        
        storageContract.setTextRecord(SUB_NODE, key, value);
        
        string memory storedValue = storageContract.textRecords(SUB_NODE, key);
        assertEq(storedValue, value);
    }
    
    // 测试设置内容哈希
    function testSetContentHash() public {
        bytes memory hash = hex"1220c3c4733ec8affd06cf9e9ff50ffc6bcd2ec85a6170004bb709669c31de94391a";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.ContentHashSet(SUB_NODE, hash);
        
        storageContract.setContentHash(SUB_NODE, hash);
        
        bytes memory storedHash = storageContract.contentHashes(SUB_NODE);
        assertEq(storedHash, hash);
    }
    
    // 测试设置头像
    function testSetAvatar() public {
        string memory avatarUrl = "ipfs://QmUUzaZxNvMJg6UruLo5vVSjcpnT6GfiHNufdpFLfYEWQh";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.AvatarSet(SUB_NODE, avatarUrl);
        
        storageContract.setAvatar(SUB_NODE, avatarUrl);
        
        string memory storedUrl = storageContract.avatars(SUB_NODE);
        assertEq(storedUrl, avatarUrl);
    }
    
    // 测试设置合约名称
    function testSetContractName() public {
        string memory name = "TestContract";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.ContractNameSet(SUB_NODE, name);
        
        storageContract.setContractName(SUB_NODE, name);
        
        string memory storedName = storageContract.contractNames(SUB_NODE);
        assertEq(storedName, name);
    }
    
    // 测试设置多链地址
    function testSetMultiChainAddress() public {
        uint256 chainId = 137; // Polygon
        bytes memory addr = hex"0x1234567890123456789012345678901234567890";
        
        vm.expectEmit(true, false, false, true);
        emit StorageContract.MultiChainAddressSet(SUB_NODE, chainId, addr);
        
        storageContract.setMultiChainAddress(SUB_NODE, chainId, addr);
        
        bytes memory storedAddr = storageContract.multiChainAddresses(SUB_NODE, chainId);
        assertEq(storedAddr, addr);
    }
} 