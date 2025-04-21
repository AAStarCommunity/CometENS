// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GatewayVerifier
 * @dev 验证网关和DNS区域的合约
 */
contract GatewayVerifier is Ownable {
    // 存储已验证的网关
    mapping(address => bool) public verifiedGateways;
    
    // 存储已验证的DNS区域
    mapping(bytes32 => bool) public verifiedDNSZones;
    
    // 网关到DNS区域的映射
    mapping(address => bytes32[]) public gatewayToDNSZones;
    
    // DNS区域到网关的映射
    mapping(bytes32 => address) public dnsZoneToGateway;
    
    // 事件定义
    event GatewayVerified(address indexed gateway, bool status);
    event DNSZoneVerified(bytes32 indexed dnsZone, address indexed gateway, bool status);
    
    /**
     * @dev 构造函数
     */
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev 验证网关
     * @param gateway 网关地址
     * @param isVerified 验证状态
     */
    function verifyGateway(address gateway, bool isVerified) external onlyOwner {
        verifiedGateways[gateway] = isVerified;
        emit GatewayVerified(gateway, isVerified);
    }
    
    /**
     * @dev 验证DNS区域
     * @param dnsZone DNS区域的namehash
     * @param gateway 对应的网关地址
     * @param isVerified 验证状态
     */
    function verifyDNSZone(bytes32 dnsZone, address gateway, bool isVerified) external onlyOwner {
        // 确保网关已验证
        require(verifiedGateways[gateway], "Gateway not verified");
        
        // 设置DNS区域验证状态
        verifiedDNSZones[dnsZone] = isVerified;
        
        if (isVerified) {
            // 如果是新验证，则添加关联
            if (dnsZoneToGateway[dnsZone] == address(0)) {
                dnsZoneToGateway[dnsZone] = gateway;
                gatewayToDNSZones[gateway].push(dnsZone);
            }
        } else {
            // 如果取消验证，则清除关联
            if (dnsZoneToGateway[dnsZone] == gateway) {
                dnsZoneToGateway[dnsZone] = address(0);
                
                // 从网关的DNS区域列表中移除
                bytes32[] storage zones = gatewayToDNSZones[gateway];
                for (uint i = 0; i < zones.length; i++) {
                    if (zones[i] == dnsZone) {
                        // 将最后一个元素移动到要删除的位置，然后删除最后一个元素
                        zones[i] = zones[zones.length - 1];
                        zones.pop();
                        break;
                    }
                }
            }
        }
        
        emit DNSZoneVerified(dnsZone, gateway, isVerified);
    }
    
    /**
     * @dev 检查网关是否已验证
     * @param gateway 网关地址
     * @return 验证状态
     */
    function isGatewayVerified(address gateway) external view returns (bool) {
        return verifiedGateways[gateway];
    }
    
    /**
     * @dev 检查DNS区域是否已验证
     * @param dnsZone DNS区域的namehash
     * @return 验证状态
     */
    function isDNSZoneVerified(bytes32 dnsZone) external view returns (bool) {
        return verifiedDNSZones[dnsZone];
    }
    
    /**
     * @dev 获取网关的所有已验证DNS区域
     * @param gateway 网关地址
     * @return 验证的DNS区域列表
     */
    function getGatewayDNSZones(address gateway) external view returns (bytes32[] memory) {
        return gatewayToDNSZones[gateway];
    }
    
    /**
     * @dev 获取DNS区域的关联网关
     * @param dnsZone DNS区域的namehash
     * @return 关联的网关地址
     */
    function getDNSZoneGateway(bytes32 dnsZone) external view returns (address) {
        return dnsZoneToGateway[dnsZone];
    }
} 