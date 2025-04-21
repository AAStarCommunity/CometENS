// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ENS} from "ens-contracts/contracts/registry/ENS.sol";
import {IAddrResolver} from "ens-contracts/contracts/resolvers/profiles/IAddrResolver.sol";
import {ITextResolver} from "ens-contracts/contracts/resolvers/profiles/ITextResolver.sol";
import {IContentHashResolver} from "ens-contracts/contracts/resolvers/profiles/IContentHashResolver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./GatewayVerifier.sol";

/**
 * @title ENSResolver
 * @dev 实现ENS域名解析功能的合约
 */
contract ENSResolver is Ownable, IAddrResolver, ITextResolver, IContentHashResolver {
    ENS public ens;
    GatewayVerifier public gatewayVerifier;
    
    // 存储地址记录
    mapping(bytes32 => mapping(uint256 => bytes)) private _addresses;
    
    // 存储文本记录
    mapping(bytes32 => mapping(string => string)) private _texts;
    
    // 存储内容哈希
    mapping(bytes32 => bytes) private _contentHashes;
    
    // 事件
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);
    event ENSRegistryUpdated(address ensRegistry);
    event GatewayVerifierUpdated(address gatewayVerifier);
    
    /**
     * @dev 构造函数
     * @param _ens ENS注册表合约地址
     * @param _gatewayVerifier 网关验证器合约地址
     */
    constructor(address _ens, address _gatewayVerifier) Ownable(msg.sender) {
        ens = ENS(_ens);
        gatewayVerifier = GatewayVerifier(_gatewayVerifier);
    }
    
    /**
     * @dev 更新ENS注册表地址
     * @param _ens 新的ENS注册表地址
     */
    function updateENSRegistry(address _ens) external onlyOwner {
        require(_ens != address(0), "Invalid ENS registry address");
        ens = ENS(_ens);
        emit ENSRegistryUpdated(_ens);
    }
    
    /**
     * @dev 更新网关验证器地址
     * @param _gatewayVerifier 新的网关验证器地址
     */
    function updateGatewayVerifier(address _gatewayVerifier) external onlyOwner {
        require(_gatewayVerifier != address(0), "Invalid gateway verifier address");
        gatewayVerifier = GatewayVerifier(_gatewayVerifier);
        emit GatewayVerifierUpdated(_gatewayVerifier);
    }
    
    /**
     * @dev 检查调用者是否有权限修改节点
     * @param node 节点namehash
     */
    function authorizeNode(bytes32 node) internal view returns (bool) {
        address owner = ens.owner(node);
        // 检查是否为节点所有者或者合约所有者
        if (msg.sender == owner || msg.sender == super.owner()) {
            return true;
        }
        
        // 检查调用者是否为已验证的网关，且该节点所在的区域与网关关联
        if (gatewayVerifier.isGatewayVerified(msg.sender)) {
            bytes32[] memory zones = gatewayVerifier.getGatewayDNSZones(msg.sender);
            for (uint i = 0; i < zones.length; i++) {
                bytes32 zone = zones[i];
                // 如果节点是该区域的一部分
                if (isNodeInZone(node, zone)) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * @dev 检查节点是否在区域内
     * @param node 节点namehash
     * @param zone 区域namehash
     */
    function isNodeInZone(bytes32 node, bytes32 zone) internal pure returns (bool) {
        // 简化的检查，实际项目中可能需要更复杂的逻辑
        // 这里仅作为示例
        return node == zone || keccak256(abi.encodePacked(node)) == keccak256(abi.encodePacked(zone));
    }
    
    /**
     * @dev 设置地址（ETH）
     * @param node 节点namehash
     * @param a 要设置的地址
     */
    function setAddr(bytes32 node, address a) external override {
        require(authorizeNode(node), "Not authorized");
        _addresses[node][60] = abi.encodePacked(a);
        emit AddrChanged(node, a);
        emit AddressChanged(node, 60, abi.encodePacked(a));
    }
    
    /**
     * @dev 获取地址（ETH）
     * @param node 节点namehash
     * @return 关联的地址
     */
    function addr(bytes32 node) external view override returns (address payable) {
        bytes memory addrBytes = _addresses[node][60];
        if (addrBytes.length == 0) {
            return payable(address(0));
        }
        return payable(address(uint160(uint256(bytes32(addrBytes)))));
    }
    
    /**
     * @dev 设置多链地址
     * @param node 节点namehash
     * @param coinType 币种类型
     * @param a 地址数据
     */
    function setAddr(bytes32 node, uint coinType, bytes calldata a) external {
        require(authorizeNode(node), "Not authorized");
        _addresses[node][coinType] = a;
        emit AddressChanged(node, coinType, a);
    }
    
    /**
     * @dev 获取多链地址
     * @param node 节点namehash
     * @param coinType 币种类型
     * @return 地址数据
     */
    function addr(bytes32 node, uint coinType) external view returns (bytes memory) {
        return _addresses[node][coinType];
    }
    
    /**
     * @dev 设置文本记录
     * @param node 节点namehash
     * @param key 文本记录的键
     * @param value 文本记录的值
     */
    function setText(bytes32 node, string calldata key, string calldata value) external override {
        require(authorizeNode(node), "Not authorized");
        _texts[node][key] = value;
        emit TextChanged(node, key, key);
    }
    
    /**
     * @dev 获取文本记录
     * @param node 节点namehash
     * @param key 文本记录的键
     * @return 文本记录的值
     */
    function text(bytes32 node, string calldata key) external view override returns (string memory) {
        return _texts[node][key];
    }
    
    /**
     * @dev 设置内容哈希
     * @param node 节点namehash
     * @param hash 内容哈希
     */
    function setContenthash(bytes32 node, bytes calldata hash) external override {
        require(authorizeNode(node), "Not authorized");
        _contentHashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }
    
    /**
     * @dev 获取内容哈希
     * @param node 节点namehash
     * @return 内容哈希
     */
    function contenthash(bytes32 node) external view override returns (bytes memory) {
        return _contentHashes[node];
    }
    
    /**
     * @dev 批量设置记录
     * @param node 节点namehash
     * @param textKeys 文本记录键数组
     * @param textValues 文本记录值数组
     * @param coinTypes 币种类型数组
     * @param addresses 地址数组
     * @param contentHash 内容哈希
     */
    function setAllRecords(
        bytes32 node,
        string[] calldata textKeys,
        string[] calldata textValues,
        uint[] calldata coinTypes,
        bytes[] calldata addresses,
        bytes calldata contentHash
    ) external {
        require(authorizeNode(node), "Not authorized");
        require(textKeys.length == textValues.length, "Text arrays length mismatch");
        require(coinTypes.length == addresses.length, "Address arrays length mismatch");
        
        // 设置文本记录
        for (uint i = 0; i < textKeys.length; i++) {
            _texts[node][textKeys[i]] = textValues[i];
            emit TextChanged(node, textKeys[i], textKeys[i]);
        }
        
        // 设置地址记录
        for (uint i = 0; i < coinTypes.length; i++) {
            _addresses[node][coinTypes[i]] = addresses[i];
            emit AddressChanged(node, coinTypes[i], addresses[i]);
            
            // 如果是ETH地址，同时触发AddrChanged事件
            if (coinTypes[i] == 60 && addresses[i].length == 20) {
                address ethAddr;
                assembly {
                    ethAddr := mload(add(mload(add(addresses, 32)), 20))
                }
                emit AddrChanged(node, ethAddr);
            }
        }
        
        // 设置内容哈希
        if (contentHash.length > 0) {
            _contentHashes[node] = contentHash;
            emit ContenthashChanged(node, contentHash);
        }
    }
    
    /**
     * @dev 删除所有记录
     * @param node 节点namehash
     */
    function clearAllRecords(bytes32 node) external {
        require(authorizeNode(node), "Not authorized");
        
        // 清空ETH地址
        if (_addresses[node][60].length > 0) {
            _addresses[node][60] = "";
            emit AddrChanged(node, address(0));
            emit AddressChanged(node, 60, "");
        }
        
        // 内容哈希在此不做操作，因为我们不知道哪些键已经存在
    }
    
    /**
     * @dev 实现IERC165接口，支持接口检测
     * @param interfaceID 接口ID
     * @return 是否支持该接口
     */
    function supportsInterface(bytes4 interfaceID) external pure override returns (bool) {
        return
            interfaceID == 0x01ffc9a7 || // ERC165
            interfaceID == 0x3b3b57de || // IAddrResolver
            interfaceID == 0xf1cb7e06 || // IAddressResolver
            interfaceID == 0x59d1d43c || // ITextResolver
            interfaceID == 0xbc1c58d1;   // IContentHashResolver
    }
} 