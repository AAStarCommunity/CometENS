// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@unruggable/contracts/op/OPFaultVerifier.sol";
import "@unruggable/contracts/GatewayVM.sol";
import "@unruggable/contracts/eth/EthVerifierHooks.sol";
// import "@unruggable/test/gateway/FixedOPFaultGameFinder.sol";
import "../contracts/OPResolver.sol";

// 手动定义FixedOPFaultGameFinder合约
contract FixedOPFaultGameFinder {
    uint256 public immutable commitIndex;
    
    constructor(uint256 _commitIndex) {
        commitIndex = _commitIndex;
    }
}

/**
 * @title DeployL1Contracts
 * @dev 用于在 L1 (以太坊主网) 上部署 ENS 解析相关合约的脚本
 */
contract DeployL1Contracts is Script {
    /**
     * @dev 主要部署函数
     */
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 检查 L2 部署信息文件是否存在
        require(vm.exists("deployments/l2_contracts.env"), "L2 deployment info not found. Please deploy L2 contracts first.");
        
        // 读取 L2 部署信息
        string memory content = vm.readFile("deployments/l2_contracts.env");
        string memory storageContractAddressStr = extractValue(content, "STORAGE_CONTRACT_ADDRESS=");
        
        // 确保提取的地址不为空
        require(bytes(storageContractAddressStr).length > 0, "Failed to extract storage contract address from deployment info");
        
        // 将字符串地址转换为 address 类型
        address storageContractAddress = vm.parseAddress(storageContractAddressStr);
        
        console.log("Deploying L1 contracts...");
        console.log("Using Storage Contract Address:", storageContractAddress);
        
        vm.startBroadcast(deployerPrivateKey);

        // 1. GatewayVM是库，不能直接实例化
        // GatewayVM gatewayVM = new GatewayVM();
        // console.log("GatewayVM deployed at:", address(gatewayVM));

        // 2. 部署 EthVerifierHooks
        EthVerifierHooks hooks = new EthVerifierHooks();
        console.log("EthVerifierHooks deployed at:", address(hooks));

        // 3. 获取 Optimism 参数
        // 从环境变量或默认值获取
        address optimismPortal = vm.envOr("OPTIMISM_PORTAL", address(0xbEb5Fc579115071764c7423A4f12eDde41f106Ed));
        
        // 计算当前区块 commit index 或使用默认值
        uint256 commitIndex = vm.envOr("COMMIT_INDEX", uint256(1000));
        
        // 4. 部署 FixedOPFaultGameFinder
        FixedOPFaultGameFinder gameFinder = new FixedOPFaultGameFinder(commitIndex);
        console.log("FixedOPFaultGameFinder deployed at:", address(gameFinder));
        
        uint256 gameTypeBitMask = 1; // Optimism 的默认值
        uint256 minAgeSec = 3600; // 1小时

        // 5. 部署 OPFaultVerifier
        string[] memory gatewayUrls = new string[](1);
        gatewayUrls[0] = "https://optimism.gateway.unruggable.com";

        uint256 defaultWindow = 1000000; // 默认值

        OPFaultVerifier verifier = new OPFaultVerifier(
            gatewayUrls,
            defaultWindow,
            address(hooks),
            optimismPortal,
            address(gameFinder),
            gameTypeBitMask,
            minAgeSec
        );
        console.log("OPFaultVerifier deployed at:", address(verifier));

        // 6. 部署 OPResolver
        OPResolver resolver = new OPResolver(IGatewayVerifier(address(verifier)));
        console.log("OPResolver deployed at:", address(resolver));

        vm.stopBroadcast();
        
        // 7. 将部署地址写入文件以便后续使用
        string memory deploymentInfo = string(abi.encodePacked(
            // "GATEWAY_VM_ADDRESS=", vm.toString(address(gatewayVM)), "\n",
            "ETH_VERIFIER_HOOKS_ADDRESS=", vm.toString(address(hooks)), "\n",
            "GAME_FINDER_ADDRESS=", vm.toString(address(gameFinder)), "\n",
            "OP_FAULT_VERIFIER_ADDRESS=", vm.toString(address(verifier)), "\n",
            "OP_RESOLVER_ADDRESS=", vm.toString(address(resolver)), "\n",
            "STORAGE_CONTRACT_ADDRESS=", vm.toString(storageContractAddress), "\n"
        ));
        vm.writeFile("deployments/l1_contracts.env", deploymentInfo);
        console.log("Deployment info written to deployments/l1_contracts.env");
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