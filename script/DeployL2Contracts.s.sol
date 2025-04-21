// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@ensdomains/contracts/registry/ENSRegistry.sol";
import "../contracts/StorageContract.sol";
import "../contracts/ENSManager.sol";

/**
 * @title DeployL2Contracts
 * @dev 用于在 L2 (Optimism) 上部署 ENS 相关合约的脚本
 */
contract DeployL2Contracts is Script {
    /**
     * @dev 主要部署函数
     */
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory rootName = vm.envString("ENS_ROOT_NAME");
        bytes32 rootNode = namehash(rootName);
        
        console.log("Deploying L2 contracts for root name:", rootName);
        console.log("Root node:", vm.toString(rootNode));
        
        vm.startBroadcast(deployerPrivateKey);

        // 1. 部署 ENS Registry
        ENSRegistry registry = new ENSRegistry();
        console.log("ENS Registry deployed at:", address(registry));

        // 2. 部署存储合约
        StorageContract storageContract = new StorageContract();
        console.log("Storage Contract deployed at:", address(storageContract));

        // 3. 部署管理合约
        ENSManager manager = new ENSManager(address(registry), address(storageContract));
        console.log("ENS Manager deployed at:", address(manager));

        // 4. 设置根域名所有者为部署者
        registry.setOwner(rootNode, msg.sender);
        console.log("Root domain owner set to deployer:", msg.sender);

        vm.stopBroadcast();
        
        // 5. 将部署地址写入文件以便后续使用
        vm.createDir("deployments", true);
        
        string memory deploymentInfo = string(abi.encodePacked(
            "ENS_REGISTRY_ADDRESS=", vm.toString(address(registry)), "\n",
            "STORAGE_CONTRACT_ADDRESS=", vm.toString(address(storageContract)), "\n",
            "ENS_MANAGER_ADDRESS=", vm.toString(address(manager)), "\n"
        ));
        vm.writeFile("deployments/l2_contracts.env", deploymentInfo);
        console.log("Deployment info written to deployments/l2_contracts.env");
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
} 