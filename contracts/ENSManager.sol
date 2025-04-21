// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";
import "./StorageContract.sol";

/**
 * @title ENSManager
 * @dev 管理 ENS 域名注册和解析的合约
 */
contract ENSManager {
    ENSRegistry public ensRegistry;
    StorageContract public storageContract;
    
    // 记录域名标签到节点的映射
    mapping(bytes32 => bool) public domains;
    
    // 事件定义
    event SubdomainRegistered(bytes32 indexed parentNode, bytes32 labelHash, address indexed owner);
    event AddressSet(bytes32 indexed node, address addr);
    event TextSet(bytes32 indexed node, string key, string value);
    event ContentHashSet(bytes32 indexed node, bytes hash);
    event AvatarSet(bytes32 indexed node, string avatarUrl);
    event ContractNameSet(bytes32 indexed node, string name);
    event MultiChainAddressSet(bytes32 indexed node, uint256 chainId, bytes addr);
    
    /**
     * @dev 构造函数
     * @param _ensRegistry ENS 注册表地址
     * @param _storageContract 存储合约地址
     */
    constructor(address _ensRegistry, address _storageContract) {
        ensRegistry = ENSRegistry(_ensRegistry);
        storageContract = StorageContract(_storageContract);
    }
    
    /**
     * @dev 只允许域名所有者调用
     * @param node 域名的 namehash
     */
    modifier onlyOwner(bytes32 node) {
        require(ensRegistry.owner(node) == msg.sender, "Not the domain owner");
        _;
    }
    
    /**
     * @dev 注册子域名
     * @param parentNode 父域名的 namehash
     * @param label 子域名标签 (不含 .eth 或父域名)
     * @param owner 所有者地址
     */
    function registerSubdomain(bytes32 parentNode, string calldata label, address owner) external {
        // 计算子域名的标签哈希
        bytes32 labelHash = keccak256(bytes(label));
        
        // 计算子域名的完整哈希
        bytes32 subnode = keccak256(abi.encodePacked(parentNode, labelHash));
        
        // 检查调用者是否为父域名的所有者
        require(ensRegistry.owner(parentNode) == msg.sender, "Not the parent domain owner");
        
        // 在 ENS Registry 中注册域名
        ensRegistry.setSubnodeOwner(parentNode, labelHash, owner);
        
        // 在存储合约中记录
        storageContract.registerSubdomain(address(ensRegistry), parentNode, subnode, owner);
        
        emit SubdomainRegistered(parentNode, labelHash, owner);
    }
    
    /**
     * @dev 设置域名解析地址
     * @param node 域名的 namehash
     * @param addr 解析地址
     */
    function setAddr(bytes32 node, address addr) external onlyOwner(node) {
        storageContract.setResolvedAddress(node, addr);
        emit AddressSet(node, addr);
    }
    
    /**
     * @dev 设置文本记录
     * @param node 域名的 namehash
     * @param key 记录键
     * @param value 记录值
     */
    function setText(bytes32 node, string calldata key, string calldata value) external onlyOwner(node) {
        storageContract.setTextRecord(node, key, value);
        emit TextSet(node, key, value);
    }
    
    /**
     * @dev 设置内容哈希
     * @param node 域名的 namehash
     * @param hash 内容哈希
     */
    function setContentHash(bytes32 node, bytes calldata hash) external onlyOwner(node) {
        storageContract.setContentHash(node, hash);
        emit ContentHashSet(node, hash);
    }
    
    /**
     * @dev 设置头像
     * @param node 域名的 namehash
     * @param avatarUrl 头像 URL
     */
    function setAvatar(bytes32 node, string calldata avatarUrl) external onlyOwner(node) {
        storageContract.setAvatar(node, avatarUrl);
        emit AvatarSet(node, avatarUrl);
    }
    
    /**
     * @dev 设置合约名称
     * @param node 域名的 namehash
     * @param name 合约名称
     */
    function setContractName(bytes32 node, string calldata name) external onlyOwner(node) {
        storageContract.setContractName(node, name);
        emit ContractNameSet(node, name);
    }
    
    /**
     * @dev 设置多链地址
     * @param node 域名的 namehash
     * @param chainId 链 ID
     * @param addr 地址字节
     */
    function setMultiChainAddress(bytes32 node, uint256 chainId, bytes calldata addr) external onlyOwner(node) {
        storageContract.setMultiChainAddress(node, chainId, addr);
        emit MultiChainAddressSet(node, chainId, addr);
    }
    
    /**
     * @dev 计算 namehash
     * @param name 完整域名 (例如 "subdomain.aastar.eth")
     * @return 域名的 namehash
     */
    function namehash(string memory name) public pure returns (bytes32) {
        bytes32 node = 0x0000000000000000000000000000000000000000000000000000000000000000;
        
        if (bytes(name).length == 0) {
            return node;
        }
        
        // 按标签分割并计算 namehash
        uint256 dotPos = 0;
        uint256 len = bytes(name).length;
        
        for (uint256 i = 0; i < len; i++) {
            if (bytes(name)[i] == '.') {
                if (i - dotPos > 0) {
                    string memory label = substring(name, dotPos, i - dotPos);
                    node = keccak256(abi.encodePacked(node, keccak256(bytes(label))));
                }
                dotPos = i + 1;
            }
        }
        
        if (dotPos < len) {
            string memory label = substring(name, dotPos, len - dotPos);
            node = keccak256(abi.encodePacked(node, keccak256(bytes(label))));
        }
        
        return node;
    }
    
    /**
     * @dev 字符串截取
     * @param str 原始字符串
     * @param startIndex 起始位置
     * @param length 截取长度
     * @return 截取后的字符串
     */
    function substring(string memory str, uint256 startIndex, uint256 length) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = strBytes[startIndex + i];
        }
        return string(result);
    }
} 