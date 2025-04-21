// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title StorageContract
 * @dev 在 Optimism L2 上存储 ENS 域名解析数据的合约
 */
contract StorageContract {
    // 权限控制
    mapping(address => bool) public admins;
    
    // ENS节点到解析器的映射
    mapping(address => mapping(bytes32 => address)) public registries;
    
    // 存储域名解析数据
    mapping(bytes32 => address) public resolvedAddresses;
    
    // 存储文本记录
    mapping(bytes32 => mapping(string => string)) public textRecords;
    
    // 存储内容哈希
    mapping(bytes32 => bytes) public contentHashes;
    
    // 存储头像
    mapping(bytes32 => string) public avatars;
    
    // 存储合约名称
    mapping(bytes32 => string) public contractNames;
    
    // 存储多链地址
    mapping(bytes32 => mapping(uint256 => bytes)) public multiChainAddresses;
    
    // 事件定义
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event SubdomainRegistered(address indexed registry, bytes32 indexed parentNode, bytes32 indexed subNode, address owner);
    event AddressSet(bytes32 indexed node, address addr);
    event TextRecordSet(bytes32 indexed node, string key, string value);
    event ContentHashSet(bytes32 indexed node, bytes hash);
    event AvatarSet(bytes32 indexed node, string avatarUrl);
    event ContractNameSet(bytes32 indexed node, string name);
    event MultiChainAddressSet(bytes32 indexed node, uint256 chainId, bytes addr);
    
    /**
     * @dev 构造函数，设置合约部署者为管理员
     */
    constructor() {
        admins[msg.sender] = true;
        emit AdminAdded(msg.sender);
    }
    
    /**
     * @dev 只允许管理员调用
     */
    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }
    
    /**
     * @dev 添加管理员
     * @param admin 要添加的管理员地址
     */
    function addAdmin(address admin) external onlyAdmin {
        require(admin != address(0), "Invalid address");
        admins[admin] = true;
        emit AdminAdded(admin);
    }
    
    /**
     * @dev 移除管理员
     * @param admin 要移除的管理员地址
     */
    function removeAdmin(address admin) external onlyAdmin {
        require(admins[admin], "Not an admin");
        admins[admin] = false;
        emit AdminRemoved(admin);
    }
    
    /**
     * @dev 注册子域名
     * @param registry 注册表地址
     * @param parentNode 父域名的 namehash
     * @param subNode 子域名的 namehash
     * @param owner 所有者地址
     */
    function registerSubdomain(address registry, bytes32 parentNode, bytes32 subNode, address owner) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        registries[registry][subNode] = owner;
        emit SubdomainRegistered(registry, parentNode, subNode, owner);
    }
    
    /**
     * @dev 设置域名解析地址
     * @param node 域名的 namehash
     * @param addr 解析地址
     */
    function setResolvedAddress(bytes32 node, address addr) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        resolvedAddresses[node] = addr;
        emit AddressSet(node, addr);
    }
    
    /**
     * @dev 设置文本记录
     * @param node 域名的 namehash
     * @param key 记录键
     * @param value 记录值
     */
    function setTextRecord(bytes32 node, string calldata key, string calldata value) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        textRecords[node][key] = value;
        emit TextRecordSet(node, key, value);
    }
    
    /**
     * @dev 设置内容哈希
     * @param node 域名的 namehash
     * @param hash 内容哈希
     */
    function setContentHash(bytes32 node, bytes calldata hash) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        contentHashes[node] = hash;
        emit ContentHashSet(node, hash);
    }
    
    /**
     * @dev 设置头像
     * @param node 域名的 namehash
     * @param avatarUrl 头像URL
     */
    function setAvatar(bytes32 node, string calldata avatarUrl) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        avatars[node] = avatarUrl;
        emit AvatarSet(node, avatarUrl);
    }
    
    /**
     * @dev 设置合约名称
     * @param node 域名的 namehash
     * @param name 合约名称
     */
    function setContractName(bytes32 node, string calldata name) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        contractNames[node] = name;
        emit ContractNameSet(node, name);
    }
    
    /**
     * @dev 设置多链地址
     * @param node 域名的 namehash
     * @param chainId 链ID
     * @param addr 地址字节
     */
    function setMultiChainAddress(bytes32 node, uint256 chainId, bytes calldata addr) external {
        // 目前不做权限验证，在 ENSManager 中已有验证
        multiChainAddresses[node][chainId] = addr;
        emit MultiChainAddressSet(node, chainId, addr);
    }
    
    /**
     * @dev 批量设置文本记录
     * @param node 域名的 namehash
     * @param keys 记录键数组
     * @param values 记录值数组
     */
    function batchSetTextRecords(bytes32 node, string[] calldata keys, string[] calldata values) external {
        require(keys.length == values.length, "Keys and values length mismatch");
        
        for (uint256 i = 0; i < keys.length; i++) {
            textRecords[node][keys[i]] = values[i];
            emit TextRecordSet(node, keys[i], values[i]);
        }
    }
    
    /**
     * @dev 批量设置多链地址
     * @param node 域名的 namehash
     * @param chainIds 链ID数组
     * @param addrs 地址字节数组
     */
    function batchSetMultiChainAddresses(bytes32 node, uint256[] calldata chainIds, bytes[] calldata addrs) external {
        require(chainIds.length == addrs.length, "ChainIds and addresses length mismatch");
        
        for (uint256 i = 0; i < chainIds.length; i++) {
            multiChainAddresses[node][chainIds[i]] = addrs[i];
            emit MultiChainAddressSet(node, chainIds[i], addrs[i]);
        }
    }
} 