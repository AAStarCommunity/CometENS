// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ENS} from "ens-contracts/contracts/registry/ENS.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./StorageContract.sol";

/**
 * @title ENSManager
 * @dev 管理ENS域名的注册和解析设置
 */
contract ENSManager is Ownable {
    // 存储合约
    StorageContract public storageContract;
    
    // ENS注册表
    ENS public ensRegistry;
    
    // Gateway验证器接口
    address public gatewayVerifier;
    
    // 事件定义
    event StorageContractUpdated(address indexed storageContract);
    event ENSRegistryUpdated(address indexed ensRegistry);
    event GatewayVerifierUpdated(address indexed gatewayVerifier);
    event SubdomainRegistered(bytes32 indexed parentNode, string indexed label, address indexed owner);
    
    /**
     * @dev 构造函数
     * @param _ensRegistry ENS注册表地址
     * @param _storageContract 存储合约地址
     */
    constructor(address _ensRegistry, address _storageContract) Ownable(msg.sender) {
        ensRegistry = ENS(_ensRegistry);
        storageContract = StorageContract(_storageContract);
    }
    
    /**
     * @dev 更新存储合约地址
     * @param _storageContract 新的存储合约地址
     */
    function setStorageContract(address _storageContract) external onlyOwner {
        require(_storageContract != address(0), "Invalid storage contract address");
        storageContract = StorageContract(_storageContract);
        emit StorageContractUpdated(_storageContract);
    }
    
    /**
     * @dev 更新ENS注册表地址
     * @param _ensRegistry 新的ENS注册表地址
     */
    function setENSRegistry(address _ensRegistry) external onlyOwner {
        require(_ensRegistry != address(0), "Invalid ENS registry address");
        ensRegistry = ENS(_ensRegistry);
        emit ENSRegistryUpdated(_ensRegistry);
    }
    
    /**
     * @dev 设置Gateway验证器地址
     * @param _gatewayVerifier 新的Gateway验证器地址
     */
    function setGatewayVerifier(address _gatewayVerifier) external onlyOwner {
        gatewayVerifier = _gatewayVerifier;
        emit GatewayVerifierUpdated(_gatewayVerifier);
    }
    
    /**
     * @dev 注册子域名
     * @param parentNode 父域名的namehash
     * @param label 子域名标签
     * @param owner 所有者地址
     */
    function registerSubdomain(bytes32 parentNode, string calldata label, address owner) external {
        // 确保发送者有权限在父域名下设置子域名
        require(ensRegistry.owner(parentNode) == msg.sender, "Not authorized for parent domain");
        
        // 计算子域名的namehash
        bytes32 labelHash = keccak256(bytes(label));
        bytes32 subnode = keccak256(abi.encodePacked(parentNode, labelHash));
        
        // 在ENS注册表中设置子域名所有者
        ensRegistry.setSubnodeOwner(parentNode, labelHash, owner);
        
        // 在存储合约中注册子域名
        storageContract.registerSubdomain(address(ensRegistry), parentNode, subnode, owner);
        
        emit SubdomainRegistered(parentNode, label, owner);
    }
    
    /**
     * @dev 设置域名解析地址
     * @param node 域名的namehash
     * @param addr 解析地址
     */
    function setAddr(bytes32 node, address addr) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中设置解析地址
        storageContract.setResolvedAddress(node, addr);
    }
    
    /**
     * @dev 设置文本记录
     * @param node 域名的namehash
     * @param key 记录键
     * @param value 记录值
     */
    function setText(bytes32 node, string calldata key, string calldata value) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中设置文本记录
        storageContract.setTextRecord(node, key, value);
    }
    
    /**
     * @dev 设置内容哈希
     * @param node 域名的namehash
     * @param hash 内容哈希
     */
    function setContentHash(bytes32 node, bytes calldata hash) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中设置内容哈希
        storageContract.setContentHash(node, hash);
    }
    
    /**
     * @dev 设置头像
     * @param node 域名的namehash
     * @param avatarUrl 头像URL
     */
    function setAvatar(bytes32 node, string calldata avatarUrl) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中设置头像
        storageContract.setAvatar(node, avatarUrl);
    }
    
    /**
     * @dev 设置合约名称
     * @param node 域名的namehash
     * @param name 合约名称
     */
    function setContractName(bytes32 node, string calldata name) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中设置合约名称
        storageContract.setContractName(node, name);
    }
    
    /**
     * @dev 设置多链地址
     * @param node 域名的namehash
     * @param chainId 链ID
     * @param addr 地址字节
     */
    function setMultiChainAddress(bytes32 node, uint256 chainId, bytes calldata addr) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中设置多链地址
        storageContract.setMultiChainAddress(node, chainId, addr);
    }
    
    /**
     * @dev 批量设置文本记录
     * @param node 域名的namehash
     * @param keys 记录键数组
     * @param values 记录值数组
     */
    function batchSetTextRecords(bytes32 node, string[] calldata keys, string[] calldata values) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中批量设置文本记录
        storageContract.batchSetTextRecords(node, keys, values);
    }
    
    /**
     * @dev 批量设置多链地址
     * @param node 域名的namehash
     * @param chainIds 链ID数组
     * @param addrs 地址字节数组
     */
    function batchSetMultiChainAddresses(bytes32 node, uint256[] calldata chainIds, bytes[] calldata addrs) external {
        // 确保发送者有权限设置域名
        require(ensRegistry.owner(node) == msg.sender, "Not authorized");
        
        // 在存储合约中批量设置多链地址
        storageContract.batchSetMultiChainAddresses(node, chainIds, addrs);
    }
} 