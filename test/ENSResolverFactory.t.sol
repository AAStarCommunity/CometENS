// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../contracts/ENSResolverFactory.sol";
import "../contracts/ENSResolver.sol";
import "../contracts/GatewayVerifier.sol";
import "@ensdomains/contracts/registry/ENSRegistry.sol";

/**
 * @title ENSResolverFactoryTest
 * @dev 测试ENSResolverFactory合约的功能
 */
contract ENSResolverFactoryTest is Test {
    ENSResolverFactory public factory;
    GatewayVerifier public gatewayVerifier;
    ENSRegistry public ensRegistry;
    
    // 测试账户
    address public deployer = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    function setUp() public {
        // 设置部署者地址
        vm.startPrank(deployer);
        
        // 部署依赖合约
        ensRegistry = new ENSRegistry();
        gatewayVerifier = new GatewayVerifier();
        
        // 部署工厂合约
        factory = new ENSResolverFactory(address(ensRegistry), address(gatewayVerifier));
        
        vm.stopPrank();
    }
    
    /**
     * @dev 测试创建解析器功能
     */
    function testCreateResolver() public {
        // 切换到user1地址
        vm.startPrank(user1);
        
        // 创建解析器前检查数量
        assertEq(factory.getResolverCount(), 0);
        assertEq(factory.getUserResolverCount(user1), 0);
        
        // 创建解析器
        address resolverAddr = factory.createResolver("User1Resolver");
        
        // 验证解析器创建成功
        assertEq(factory.getResolverCount(), 1);
        assertEq(factory.getUserResolverCount(user1), 1);
        
        // 验证解析器在用户列表中
        address[] memory userResolvers = factory.getUserResolvers(user1);
        assertEq(userResolvers.length, 1);
        assertEq(userResolvers[0], resolverAddr);
        
        // 验证解析器在全局列表中
        assertEq(factory.allResolvers(0), resolverAddr);
        
        // 验证解析器的所有权已经转移给user1
        ENSResolver resolver = ENSResolver(resolverAddr);
        assertEq(resolver.owner(), user1);
        
        vm.stopPrank();
    }
    
    /**
     * @dev 测试多个用户创建解析器
     */
    function testMultipleUsers() public {
        // 用户1创建解析器
        vm.prank(user1);
        address resolver1 = factory.createResolver("User1Resolver");
        
        // 用户2创建两个解析器
        vm.startPrank(user2);
        address resolver2 = factory.createResolver("User2Resolver1");
        address resolver3 = factory.createResolver("User2Resolver2");
        vm.stopPrank();
        
        // 验证全局解析器数量
        assertEq(factory.getResolverCount(), 3);
        
        // 验证用户1的解析器
        assertEq(factory.getUserResolverCount(user1), 1);
        address[] memory user1Resolvers = factory.getUserResolvers(user1);
        assertEq(user1Resolvers.length, 1);
        assertEq(user1Resolvers[0], resolver1);
        
        // 验证用户2的解析器
        assertEq(factory.getUserResolverCount(user2), 2);
        address[] memory user2Resolvers = factory.getUserResolvers(user2);
        assertEq(user2Resolvers.length, 2);
        assertEq(user2Resolvers[0], resolver2);
        assertEq(user2Resolvers[1], resolver3);
    }
    
    /**
     * @dev 测试更新ENS注册表地址
     */
    function testUpdateENSRegistry() public {
        // 部署新的ENS注册表
        ENSRegistry newRegistry = new ENSRegistry();
        
        // 非所有者不能更新
        vm.prank(user1);
        vm.expectRevert();
        factory.updateENSRegistry(address(newRegistry));
        
        // 所有者可以更新
        vm.prank(deployer);
        factory.updateENSRegistry(address(newRegistry));
        
        // 验证更新成功
        assertEq(factory.ensRegistry(), address(newRegistry));
    }
    
    /**
     * @dev 测试更新GatewayVerifier地址
     */
    function testUpdateGatewayVerifier() public {
        // 部署新的GatewayVerifier
        GatewayVerifier newVerifier = new GatewayVerifier();
        
        // 非所有者不能更新
        vm.prank(user1);
        vm.expectRevert();
        factory.updateGatewayVerifier(address(newVerifier));
        
        // 所有者可以更新
        vm.prank(deployer);
        factory.updateGatewayVerifier(address(newVerifier));
        
        // 验证更新成功
        assertEq(address(factory.gatewayVerifier()), address(newVerifier));
    }
} 