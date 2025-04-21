// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title IGatewayVerifier
 * @dev Gateway 验证器接口
 */
interface IGatewayVerifier {
    /**
     * @dev 验证从 Gateway 获取的调用结果
     * @param target 目标合约
     * @param callData 调用数据
     * @param response Gateway 响应数据
     * @return 验证后的数据
     */
    function validateCall(
        address target,
        bytes memory callData,
        bytes calldata response
    ) external view returns (bytes memory);
} 