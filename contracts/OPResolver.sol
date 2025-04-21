// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./IGatewayVerifier.sol";

interface IGatewayVMOPResolver {
    function resolvedAddresses(bytes32 node) external view returns (address);
    function textRecords(bytes32 node, string memory key) external view returns (string memory);
    function contentHashes(bytes32 node) external view returns (bytes memory);
    function avatars(bytes32 node) external view returns (string memory);
    function contractNames(bytes32 node) external view returns (string memory);
    function multiChainAddresses(bytes32 node, uint256 chainId) external view returns (bytes memory);
}

/**
 * @title OPResolver
 * @dev 实现 EIP-3668 CCIP Read 协议，从 Optimism L2 读取 ENS 解析数据
 */
contract OPResolver {
    IGatewayVerifier public immutable verifier;
    
    // ENS查询函数 ID
    bytes4 private constant ADDR_SELECTOR = bytes4(keccak256("addr(bytes32)"));
    bytes4 private constant TEXT_SELECTOR = bytes4(keccak256("text(bytes32,string)"));
    bytes4 private constant CONTENTHASH_SELECTOR = bytes4(keccak256("contenthash(bytes32)"));
    bytes4 private constant AVATAR_SELECTOR = bytes4(keccak256("avatar(bytes32)"));
    bytes4 private constant CONTRACTNAME_SELECTOR = bytes4(keccak256("contractName(bytes32)"));
    bytes4 private constant MULTICHAINSELECTOR = bytes4(keccak256("addr(bytes32,uint256)"));
    
    // 存储合约方法 ID
    bytes4 private constant RESOLVE_ADDR_SELECTOR = bytes4(keccak256("resolvedAddresses(bytes32)"));
    bytes4 private constant RESOLVE_TEXT_SELECTOR = bytes4(keccak256("textRecords(bytes32,string)"));
    bytes4 private constant RESOLVE_CONTENTHASH_SELECTOR = bytes4(keccak256("contentHashes(bytes32)"));
    bytes4 private constant RESOLVE_AVATAR_SELECTOR = bytes4(keccak256("avatars(bytes32)"));
    bytes4 private constant RESOLVE_CONTRACTNAME_SELECTOR = bytes4(keccak256("contractNames(bytes32)"));
    bytes4 private constant RESOLVE_MULTICHAIN_SELECTOR = bytes4(keccak256("multiChainAddresses(bytes32,uint256)"));
    
    // Gateway URL
    string public constant gatewayUrl = "https://optimism.gateway.unruggable.com";
    
    /**
     * @dev 构造函数
     * @param _verifier Gateway 验证器合约地址
     */
    constructor(IGatewayVerifier _verifier) {
        verifier = _verifier;
    }
    
    /**
     * @dev 实现 EIP-3668 的回调处理
     * @param data 包含从 L2 获取的数据
     * @param extraData 额外参数数据
     * @return 解码后的结果
     */
    function validateAndDecode(bytes calldata data, bytes calldata extraData) external view returns (bytes memory) {
        // 从 extraData 中获取目标合约和函数选择器
        (address targetContract, bytes4 funcSelector, bytes memory callData) = abi.decode(extraData, (address, bytes4, bytes));
        
        // 验证数据证明
        bytes memory validatedData = verifier.validateCall(targetContract, callData, data);
        
        // 解析不同类型的解析请求
        if (funcSelector == ADDR_SELECTOR) {
            address addr = abi.decode(validatedData, (address));
            return abi.encode(addr);
        } else if (funcSelector == TEXT_SELECTOR) {
            string memory text = abi.decode(validatedData, (string));
            return abi.encode(text);
        } else if (funcSelector == CONTENTHASH_SELECTOR) {
            bytes memory hash = abi.decode(validatedData, (bytes));
            return abi.encode(hash);
        } else if (funcSelector == AVATAR_SELECTOR) {
            string memory avatarUrl = abi.decode(validatedData, (string));
            return abi.encode(avatarUrl);
        } else if (funcSelector == CONTRACTNAME_SELECTOR) {
            string memory name = abi.decode(validatedData, (string));
            return abi.encode(name);
        } else if (funcSelector == MULTICHAINSELECTOR) {
            bytes memory addrBytes = abi.decode(validatedData, (bytes));
            return abi.encode(addrBytes);
        }
        
        revert("Unknown function selector");
    }
    
    /**
     * @dev 解析 ENS 名称到以太坊地址
     * @param node 域名的 namehash
     * @return 解析的地址
     */
    function addr(bytes32 node) external view returns (address) {
        // 创建调用 L2 合约的 calldata
        bytes memory callData = abi.encodeWithSelector(RESOLVE_ADDR_SELECTOR, node);
        
        // 构建额外数据
        bytes memory extraData = abi.encode(address(0), ADDR_SELECTOR, callData);
        
        // 生成并抛出 OffchainLookup 错误
        bytes memory offchainLookup = abi.encodeWithSignature(
            "OffchainLookup(address,string[],bytes,bytes4,bytes)",
            address(this),
            _getUrls(),
            callData,
            this.validateAndDecode.selector,
            extraData
        );
        
        // 使用内联汇编抛出错误
        assembly {
            revert(add(offchainLookup, 0x20), mload(offchainLookup))
        }
    }
    
    /**
     * @dev 解析多链地址
     * @param node 域名的 namehash
     * @param chainId 链ID
     * @return 解析的地址
     */
    function addr(bytes32 node, uint256 chainId) external view returns (bytes memory) {
        // 创建调用 L2 合约的 calldata
        bytes memory callData = abi.encodeWithSelector(RESOLVE_MULTICHAIN_SELECTOR, node, chainId);
        
        // 构建额外数据
        bytes memory extraData = abi.encode(address(0), MULTICHAINSELECTOR, callData);
        
        // 生成并抛出 OffchainLookup 错误
        bytes memory offchainLookup = abi.encodeWithSignature(
            "OffchainLookup(address,string[],bytes,bytes4,bytes)",
            address(this),
            _getUrls(),
            callData,
            this.validateAndDecode.selector,
            extraData
        );
        
        // 使用内联汇编抛出错误
        assembly {
            revert(add(offchainLookup, 0x20), mload(offchainLookup))
        }
    }
    
    /**
     * @dev 获取 URLs 数组
     * @return 包含 gateway URL 的数组
     */
    function _getUrls() internal pure returns (string[] memory) {
        string[] memory urls = new string[](1);
        urls[0] = gatewayUrl;
        return urls;
    }
    
    /**
     * @dev 解析文本记录
     * @param node 域名的 namehash
     * @param key 文本记录的键
     * @return 文本记录的值
     */
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        // 创建调用 L2 合约的 calldata
        bytes memory callData = abi.encodeWithSelector(RESOLVE_TEXT_SELECTOR, node, key);
        
        // 构建额外数据
        bytes memory extraData = abi.encode(address(0), TEXT_SELECTOR, callData);
        
        // 生成并抛出 OffchainLookup 错误
        bytes memory offchainLookup = abi.encodeWithSignature(
            "OffchainLookup(address,string[],bytes,bytes4,bytes)",
            address(this),
            _getUrls(),
            callData,
            this.validateAndDecode.selector,
            extraData
        );
        
        // 使用内联汇编抛出错误
        assembly {
            revert(add(offchainLookup, 0x20), mload(offchainLookup))
        }
    }
    
    /**
     * @dev 解析内容哈希
     * @param node 域名的 namehash
     * @return 内容哈希
     */
    function contenthash(bytes32 node) external view returns (bytes memory) {
        // 创建调用 L2 合约的 calldata
        bytes memory callData = abi.encodeWithSelector(RESOLVE_CONTENTHASH_SELECTOR, node);
        
        // 构建额外数据
        bytes memory extraData = abi.encode(address(0), CONTENTHASH_SELECTOR, callData);
        
        // 生成并抛出 OffchainLookup 错误
        bytes memory offchainLookup = abi.encodeWithSignature(
            "OffchainLookup(address,string[],bytes,bytes4,bytes)",
            address(this),
            _getUrls(),
            callData,
            this.validateAndDecode.selector,
            extraData
        );
        
        // 使用内联汇编抛出错误
        assembly {
            revert(add(offchainLookup, 0x20), mload(offchainLookup))
        }
    }
    
    /**
     * @dev 解析头像
     * @param node 域名的 namehash
     * @return 头像URL
     */
    function avatar(bytes32 node) external view returns (string memory) {
        // 创建调用 L2 合约的 calldata
        bytes memory callData = abi.encodeWithSelector(RESOLVE_AVATAR_SELECTOR, node);
        
        // 构建额外数据
        bytes memory extraData = abi.encode(address(0), AVATAR_SELECTOR, callData);
        
        // 生成并抛出 OffchainLookup 错误
        bytes memory offchainLookup = abi.encodeWithSignature(
            "OffchainLookup(address,string[],bytes,bytes4,bytes)",
            address(this),
            _getUrls(),
            callData,
            this.validateAndDecode.selector,
            extraData
        );
        
        // 使用内联汇编抛出错误
        assembly {
            revert(add(offchainLookup, 0x20), mload(offchainLookup))
        }
    }
    
    /**
     * @dev 解析合约名称
     * @param node 域名的 namehash
     * @return 合约名称
     */
    function contractName(bytes32 node) external view returns (string memory) {
        // 创建调用 L2 合约的 calldata
        bytes memory callData = abi.encodeWithSelector(RESOLVE_CONTRACTNAME_SELECTOR, node);
        
        // 构建额外数据
        bytes memory extraData = abi.encode(address(0), CONTRACTNAME_SELECTOR, callData);
        
        // 生成并抛出 OffchainLookup 错误
        bytes memory offchainLookup = abi.encodeWithSignature(
            "OffchainLookup(address,string[],bytes,bytes4,bytes)",
            address(this),
            _getUrls(),
            callData,
            this.validateAndDecode.selector,
            extraData
        );
        
        // 使用内联汇编抛出错误
        assembly {
            revert(add(offchainLookup, 0x20), mload(offchainLookup))
        }
    }
    
    /**
     * @dev ERC165 接口支持检查
     * @param interfaceID 接口ID
     * @return 是否支持该接口
     */
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == 0x01ffc9a7 || // ERC165
               interfaceID == 0x3b3b57de || // addr(bytes32)
               interfaceID == 0xf1cb7e06 || // addr(bytes32,uint256)
               interfaceID == 0x59d1d43c || // text(bytes32,string)
               interfaceID == 0xbc1c58d1 || // contenthash(bytes32)
               interfaceID == 0x2203ab56 || // avatar(bytes32)
               interfaceID == 0xd9b27f0c;   // contractName(bytes32)
    }
}