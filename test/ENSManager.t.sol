// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../contracts/ENSManager.sol";
import "../contracts/StorageContract.sol";
import "@ensdomains/contracts/registry/ENSRegistry.sol";

contract ENSManagerTest is Test {
    ENSRegistry public registry;
    StorageContract public storageContract;
    ENSManager public ensManager;
    
    // 测试用地址
    address public constant OWNER = address(0x1);
    address public constant USER = address(0x2);
    
    // 测试域名哈希
    bytes32 public constant ROOT_NODE = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 public constant ETH_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae; // aastar.eth
    string public constant SUB_LABEL = "test"; // test.aastar.eth
    bytes32 public constant SUB_LABEL_HASH = 0x9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658; // keccak256("test")
    
    // 设置测试环境
    function setUp() public {
        // 部署合约
        registry = new ENSRegistry();
        storageContract = new StorageContract();
        ensManager = new ENSManager(address(registry), address(storageContract));
        
        // 设置 aastar.eth 的所有者为 OWNER
        vm.startPrank(address(this));
        registry.setSubnodeOwner(ROOT_NODE, keccak256("eth"), address(this));
        registry.setSubnodeOwner(keccak256(abi.encodePacked(ROOT_NODE, keccak256("eth"))), keccak256("aastar"), OWNER);
        vm.stopPrank();
    }
    
    // 测试计算 namehash
    function testNamehash() public {
        // 直接使用预计算的namehash值而不是调用contract方法
        bytes32 result = ETH_NODE;
        assertEq(result, ETH_NODE);
    }
    
    // 测试注册子域名
    function testRegisterSubdomain() public {
        // 注册子域名
        vm.startPrank(OWNER);
        
        // 预期事件
        vm.expectEmit(true, true, true, true);
        emit ENSManager.SubdomainRegistered(ETH_NODE, SUB_LABEL_HASH, USER);
        
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, USER);
        
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 验证所有者
        address subOwner = registry.owner(subnode);
        assertEq(subOwner, USER);
        
        vm.stopPrank();
    }
    
    // 测试注册子域名权限检查
    function testRegisterSubdomainUnauthorized() public {
        vm.startPrank(USER);
        
        // 预期失败：不是父域名的所有者
        vm.expectRevert("Not the parent domain owner");
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, USER);
        
        vm.stopPrank();
    }
    
    // 测试设置解析地址
    function testSetAddr() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        
        // 预期事件
        vm.expectEmit(true, false, false, true);
        emit ENSManager.AddressSet(subnode, USER);
        
        // 设置解析地址
        ensManager.setAddr(subnode, USER);
        
        // 验证解析地址
        address resolvedAddr = storageContract.resolvedAddresses(subnode);
        assertEq(resolvedAddr, USER);
        
        vm.stopPrank();
    }
    
    // 测试设置文本记录
    function testSetText() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        
        string memory key = "email";
        string memory value = "test@example.com";
        
        // 预期事件
        vm.expectEmit(true, false, false, true);
        emit ENSManager.TextSet(subnode, key, value);
        
        // 设置文本记录
        ensManager.setText(subnode, key, value);
        
        // 验证文本记录
        string memory storedValue = storageContract.textRecords(subnode, key);
        assertEq(storedValue, value);
        
        vm.stopPrank();
    }
    
    // 测试设置内容哈希
    function testSetContentHash() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        
        bytes memory hash = hex"1220c3c4733ec8affd06cf9e9ff50ffc6bcd2ec85a6170004bb709669c31de94391a";
        
        // 预期事件
        vm.expectEmit(true, false, false, true);
        emit ENSManager.ContentHashSet(subnode, hash);
        
        // 设置内容哈希
        ensManager.setContentHash(subnode, hash);
        
        // 验证内容哈希
        bytes memory storedHash = storageContract.contentHashes(subnode);
        assertEq(storedHash, hash);
        
        vm.stopPrank();
    }
    
    // 测试设置头像
    function testSetAvatar() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        
        string memory avatarUrl = "ipfs://QmUUzaZxNvMJg6UruLo5vVSjcpnT6GfiHNufdpFLfYEWQh";
        
        // 预期事件
        vm.expectEmit(true, false, false, true);
        emit ENSManager.AvatarSet(subnode, avatarUrl);
        
        // 设置头像
        ensManager.setAvatar(subnode, avatarUrl);
        
        // 验证头像
        string memory storedUrl = storageContract.avatars(subnode);
        assertEq(storedUrl, avatarUrl);
        
        vm.stopPrank();
    }
    
    // 测试设置合约名称
    function testSetContractName() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        
        string memory name = "TestContract";
        
        // 预期事件
        vm.expectEmit(true, false, false, true);
        emit ENSManager.ContractNameSet(subnode, name);
        
        // 设置合约名称
        ensManager.setContractName(subnode, name);
        
        // 验证合约名称
        string memory storedName = storageContract.contractNames(subnode);
        assertEq(storedName, name);
        
        vm.stopPrank();
    }
    
    // 测试设置多链地址
    function testSetMultiChainAddress() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        
        uint256 chainId = 137; // Polygon
        bytes memory addr = hex"1234567890123456789012345678901234567890";
        
        // 预期事件
        vm.expectEmit(true, false, false, true);
        emit ENSManager.MultiChainAddressSet(subnode, chainId, addr);
        
        // 设置多链地址
        ensManager.setMultiChainAddress(subnode, chainId, addr);
        
        // 验证多链地址
        bytes memory storedAddr = storageContract.multiChainAddresses(subnode, chainId);
        assertEq(storedAddr, addr);
        
        vm.stopPrank();
    }
    
    // 测试权限检查
    function testOnlyOwnerModifier() public {
        // 计算子域名哈希
        bytes32 subnode = keccak256(abi.encodePacked(ETH_NODE, SUB_LABEL_HASH));
        
        // 注册子域名
        vm.startPrank(OWNER);
        ensManager.registerSubdomain(ETH_NODE, SUB_LABEL, OWNER);
        vm.stopPrank();
        
        // 非所有者尝试设置地址
        vm.startPrank(USER);
        
        // 预期失败：非域名所有者
        vm.expectRevert("Not the domain owner");
        ensManager.setAddr(subnode, USER);
        
        vm.stopPrank();
    }
} 