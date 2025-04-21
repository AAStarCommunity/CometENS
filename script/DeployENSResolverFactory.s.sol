// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../contracts/ENSResolverFactory.sol";
import "../contracts/GatewayVerifier.sol";

/**
 * @title DeployENSResolverFactory
 * @dev 用于部署ENSResolverFactory及其依赖合约的脚本
 */
contract DeployENSResolverFactory is Script {
    /**
     * @dev 主要部署函数
     */
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 尝试从环境变量获取ENS注册表地址，如果不存在则使用以太坊主网上的ENS注册表地址
        address ensRegistry = vm.envOr("ENS_REGISTRY_ADDRESS", address(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e));
        
        console.log("Deploying ENSResolverFactory and dependencies...");
        console.log("Using ENS Registry Address:", ensRegistry);
        
        vm.startBroadcast(deployerPrivateKey);

        // 1. 部署GatewayVerifier (如果已经部署过，可以使用现有的)
        GatewayVerifier gatewayVerifier;
        
        // 尝试从环境变量获取已存在的GatewayVerifier地址
        address existingGatewayVerifier = vm.envOr("GATEWAY_VERIFIER_ADDRESS", address(0));
        
        if (existingGatewayVerifier != address(0)) {
            // 使用已存在的GatewayVerifier
            gatewayVerifier = GatewayVerifier(existingGatewayVerifier);
            console.log("Using existing GatewayVerifier at:", address(gatewayVerifier));
        } else {
            // 部署新的GatewayVerifier
            gatewayVerifier = new GatewayVerifier();
            console.log("GatewayVerifier deployed at:", address(gatewayVerifier));
        }

        // 2. 部署ENSResolverFactory
        ENSResolverFactory factory = new ENSResolverFactory(ensRegistry, address(gatewayVerifier));
        console.log("ENSResolverFactory deployed at:", address(factory));

        vm.stopBroadcast();
        
        // 3. 将部署地址写入文件以便后续使用
        vm.createDir("deployments", true);
        
        string memory deploymentInfo = string(abi.encodePacked(
            "ENS_REGISTRY_ADDRESS=", vm.toString(ensRegistry), "\n",
            "GATEWAY_VERIFIER_ADDRESS=", vm.toString(address(gatewayVerifier)), "\n",
            "ENS_RESOLVER_FACTORY_ADDRESS=", vm.toString(address(factory)), "\n"
        ));
        vm.writeFile("deployments/resolver_factory.env", deploymentInfo);
        console.log("Deployment info written to deployments/resolver_factory.env");
    }
} 