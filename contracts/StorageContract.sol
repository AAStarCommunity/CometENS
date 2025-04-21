// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title StorageContract
 * @dev 存储域名解析数据的合约，用于 L2 (Optimism) 上的 ENS 域名解析
 */
contract StorageContract {
    // ENS节点到解析器的映射 (registry => node => owner)
    mapping(address => mapping(bytes32 => address)) public registries;
    
    // 存储域名解析数据 (node => address)
    mapping(bytes32 => address) public resolvedAddresses;
    
    // 存储文本记录 (node => key => value)
    mapping(bytes32 => mapping(string => string)) public textRecords;
    
    // 存储内容哈希 (node => contentHash)
    mapping(bytes32 => bytes) public contentHashes;
    
    // 存储头像 (node => avatarUrl)
    mapping(bytes32 => string) public avatars;
    
    // 存储合约名称 (node => contractName)
    mapping(bytes32 => string) public contractNames;
    
    // 存储多链地址 (node => chainId => address)
    mapping(bytes32 => mapping(uint256 => bytes)) public multiChainAddresses;
    
    // 事件定义
    event SubdomainRegistered(address indexed registry, bytes32 indexed parentNode, bytes32 indexed subNode, address owner);
    event AddressSet(bytes32 indexed node, address addr);
    event TextRecordSet(bytes32 indexed node, string key, string value);
    event ContentHashSet(bytes32 indexed node, bytes hash);
    event AvatarSet(bytes32 indexed node, string avatarUrl);
    event ContractNameSet(bytes32 indexed node, string name);
    event MultiChainAddressSet(bytes32 indexed node, uint256 chainId, bytes addr);

    /**
     * @dev 注册子域名
     * @param registry ENS注册表地址
     * @param parentNode 父域名的namehash
     * @param subNode 子域名的namehash
     * @param owner 所有者地址
     */
    function registerSubdomain(address registry, bytes32 parentNode, bytes32 subNode, address owner) external {
        require(msg.sender == owner, "Not authorized");
        registries[registry][subNode] = owner;
        emit SubdomainRegistered(registry, parentNode, subNode, owner);
    }
    
    /**
     * @dev 设置解析地址
     * @param node 域名的namehash
     * @param addr 解析地址
     */
    function setResolvedAddress(bytes32 node, address addr) external {
        resolvedAddresses[node] = addr;
        emit AddressSet(node, addr);
    }
    
    /**
     * @dev 设置文本记录
     * @param node 域名的namehash
     * @param key 记录键
     * @param value 记录值
     */
    function setTextRecord(bytes32 node, string calldata key, string calldata value) external {
        textRecords[node][key] = value;
        emit TextRecordSet(node, key, value);
    }
    
    /**
     * @dev 设置内容哈希
     * @param node 域名的namehash
     * @param hash 内容哈希
     */
    function setContentHash(bytes32 node, bytes calldata hash) external {
        contentHashes[node] = hash;
        emit ContentHashSet(node, hash);
    }
    
    /**
     * @dev 设置头像
     * @param node 域名的namehash
     * @param avatarUrl 头像URL
     */
    function setAvatar(bytes32 node, string calldata avatarUrl) external {
        avatars[node] = avatarUrl;
        emit AvatarSet(node, avatarUrl);
    }
    
    /**
     * @dev 设置合约名称
     * @param node 域名的namehash
     * @param name 合约名称
     */
    function setContractName(bytes32 node, string calldata name) external {
        contractNames[node] = name;
        emit ContractNameSet(node, name);
    }
    
    /**
     * @dev 设置多链地址
     * @param node 域名的namehash
     * @param chainId 链ID
     * @param addr 地址字节
     */
    function setMultiChainAddress(bytes32 node, uint256 chainId, bytes calldata addr) external {
        multiChainAddresses[node][chainId] = addr;
        emit MultiChainAddressSet(node, chainId, addr);
    }
} 