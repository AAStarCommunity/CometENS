// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ENSResolver} from "./ENSResolver.sol";
import {GatewayVerifier} from "./GatewayVerifier.sol";

/**
 * @title ENSResolverFactory
 * @dev 用于创建和管理ENS解析器实例的工厂合约
 */
contract ENSResolverFactory is Ownable {
    // ENS注册表地址
    address public ensRegistry;
    
    // 网关验证器合约地址
    GatewayVerifier public gatewayVerifier;
    
    // 存储所有创建的解析器地址
    address[] public allResolvers;
    
    // 映射用户地址到其创建的解析器
    mapping(address => address[]) public userResolvers;
    
    // 事件
    event ResolverCreated(address indexed creator, address indexed resolver, string name);
    event ENSRegistryUpdated(address ensRegistry);
    event GatewayVerifierUpdated(address gatewayVerifier);
    
    /**
     * @dev 构造函数
     * @param _ensRegistry ENS注册表地址
     * @param _gatewayVerifier 网关验证器合约地址
     */
    constructor(address _ensRegistry, address _gatewayVerifier) Ownable(msg.sender) {
        require(_ensRegistry != address(0), "Invalid ENS registry address");
        require(_gatewayVerifier != address(0), "Invalid gateway verifier address");
        
        ensRegistry = _ensRegistry;
        gatewayVerifier = GatewayVerifier(_gatewayVerifier);
    }
    
    /**
     * @dev 更新ENS注册表地址
     * @param _ensRegistry 新的ENS注册表地址
     */
    function updateENSRegistry(address _ensRegistry) external onlyOwner {
        require(_ensRegistry != address(0), "Invalid ENS registry address");
        ensRegistry = _ensRegistry;
        emit ENSRegistryUpdated(_ensRegistry);
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
     * @dev 创建新的ENS解析器
     * @param name 解析器名称（用于识别，不是功能性的）
     * @return 创建的解析器合约地址
     */
    function createResolver(string calldata name) external returns (address) {
        ENSResolver resolver = new ENSResolver(ensRegistry, address(gatewayVerifier));
        
        // 将所有权转移给创建者
        resolver.transferOwnership(msg.sender);
        
        // 添加到全局解析器列表
        allResolvers.push(address(resolver));
        
        // 添加到用户的解析器列表
        userResolvers[msg.sender].push(address(resolver));
        
        emit ResolverCreated(msg.sender, address(resolver), name);
        
        return address(resolver);
    }
    
    /**
     * @dev 获取所有创建的解析器数量
     * @return 解析器数量
     */
    function getResolverCount() external view returns (uint) {
        return allResolvers.length;
    }
    
    /**
     * @dev 获取用户创建的解析器数量
     * @param user 用户地址
     * @return 该用户创建的解析器数量
     */
    function getUserResolverCount(address user) external view returns (uint) {
        return userResolvers[user].length;
    }
    
    /**
     * @dev 获取用户创建的所有解析器地址
     * @param user 用户地址
     * @return 该用户创建的解析器地址数组
     */
    function getUserResolvers(address user) external view returns (address[] memory) {
        return userResolvers[user];
    }
} 