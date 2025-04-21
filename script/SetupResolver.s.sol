// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@ensdomains/contracts/registry/ENSRegistry.sol";

/**
 * @title SetupResolver
 * @dev 用于在 L1 上将 ENS 域名的 Resolver 设置为我们部署的 OPResolver
 */
contract SetupResolver is Script {
    /**
     * @dev 主要设置函数
     */
    function run() external {
        uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory rootName = vm.envString("ENS_ROOT_NAME");
        
        // 检查 L1 部署信息文件是否存在
        require(vm.exists("deployments/l1_contracts.env"), "L1 deployment info not found. Please deploy L1 contracts first.");
        
        // 读取 L1 部署信息
        string memory content = vm.readFile("deployments/l1_contracts.env");
        string memory resolverAddressStr = extractValue(content, "OP_RESOLVER_ADDRESS=");
        
        // 确保提取的地址不为空
        require(bytes(resolverAddressStr).length > 0, "Failed to extract resolver address from deployment info");
        
        // 将字符串地址转换为 address 类型
        address resolverAddress = vm.parseAddress(resolverAddressStr);
        
        // 计算域名的 namehash
        bytes32 node = namehash(rootName);
        
        console.log("Setting up Resolver for domain:", rootName);
        console.log("Domain node:", vm.toString(node));
        console.log("Resolver address:", resolverAddress);
        
        vm.startBroadcast(ownerPrivateKey);

        // 以太坊主网 ENS Registry 地址
        address ensRegistry = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
        
        // 设置 Resolver
        ENSRegistry(ensRegistry).setResolver(node, resolverAddress);
        console.log("Resolver set for node:", vm.toString(node));

        vm.stopBroadcast();
        
        // 记录操作
        string memory setupInfo = string(abi.encodePacked(
            "Domain: ", rootName, "\n",
            "Node: ", vm.toString(node), "\n",
            "Resolver: ", vm.toString(resolverAddress), "\n",
            "Setup Timestamp: ", vm.toString(block.timestamp), "\n"
        ));
        vm.writeFile("deployments/resolver_setup.log", setupInfo);
        console.log("Setup info written to deployments/resolver_setup.log");
    }
    
    /**
     * @dev 计算 namehash
     * @param name 完整域名 (例如 "aastar.eth")
     * @return 域名的 namehash
     */
    function namehash(string memory name) internal pure returns (bytes32) {
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
    
    /**
     * @dev 从字符串中提取键值对
     * @param content 原始字符串
     * @param key 要查找的键
     * @return 提取的值
     */
    function extractValue(string memory content, string memory key) internal pure returns (string memory) {
        bytes memory contentBytes = bytes(content);
        bytes memory keyBytes = bytes(key);
        
        uint256 pos = indexOf(contentBytes, keyBytes, 0);
        if (pos == type(uint256).max) return "";
        
        pos += keyBytes.length;
        uint256 endPos = indexOf(contentBytes, bytes("\n"), pos);
        if (endPos == type(uint256).max) endPos = contentBytes.length;
        
        bytes memory valueBytes = new bytes(endPos - pos);
        for (uint256 i = 0; i < endPos - pos; i++) {
            valueBytes[i] = contentBytes[pos + i];
        }
        
        return string(valueBytes);
    }
    
    /**
     * @dev 查找子字符串位置
     * @param haystack 被搜索的字符串
     * @param needle 要查找的子字符串
     * @param start 开始搜索的位置
     * @return 子字符串的位置，若未找到则返回 uint256.max
     */
    function indexOf(bytes memory haystack, bytes memory needle, uint256 start) internal pure returns (uint256) {
        if (needle.length == 0) return start;
        if (haystack.length < needle.length) return type(uint256).max;
        
        for (uint256 i = start; i <= haystack.length - needle.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < needle.length; j++) {
                if (haystack[i + j] != needle[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return i;
        }
        
        return type(uint256).max;
    }
} 