# CometENS
We forked from [unruggable](https://github.com/unruggable-labs/unruggable-gateways-ens-resolution-demos) repo and extend it to CometENS core service.
<p align="center">
    <img src="https://raw.githubusercontent.com/unruggable-labs/unruggable-gateways-ens-resolution-demos/main/unruggable-logo-black.png" style = "width:300px;" alt = "Unruggable Gateways" />

<img src="https://raw.githubusercontent.com/jhfnetboy/MarkDownImg/main/img/202505271655901.png" width="35%" alt = "CometENS from   AAStar"/>    
</p>

# ENS 解析器工厂

## 项目简介

ENS 解析器工厂是一个智能合约系统，允许用户轻松创建和管理自己的 ENS（以太坊域名服务）解析器实例。这个项目使用 Unruggable Gateways 技术，支持从 Optimism Layer2 安全地获取和验证 ENS 解析数据。

## 主要特性

- 一键创建 ENS 解析器实例
- 自动转移解析器所有权给创建者
- 全局和用户级别的解析器管理
- 支持多链地址解析
- 集成网关验证机制确保数据安全性

## 架构

项目包含以下主要组件：

1. **ENSResolverFactory**: 创建和管理解析器实例的工厂合约
2. **ENSResolver**: 实现标准 ENS 解析接口的解析器合约
3. **GatewayVerifier**: 验证网关和 DNS 区域的合约
4. **部署脚本**: 简化合约部署流程
5. **测试套件**: 确保合约功能正常

有关更详细的架构说明，请参阅 [CONTRACT_RELATIONS.md](CONTRACT_RELATIONS.md)。

## 安装与使用

### 前置条件

- Foundry 工具链（安装指南：https://book.getfoundry.sh/getting-started/installation）
- Node.js 和 npm（用于前端开发）
- 以太坊钱包和一些测试网 ETH

### 安装

1. 克隆仓库：
   ```bash
   git clone https://github.com/yourusername/unruggable-gateways-ens-resolution-demos.git
   cd unruggable-gateways-ens-resolution-demos
   ```

2. 安装依赖：
   ```bash
   forge install
   ```

### 部署

1. 创建 `.env` 文件并添加以下配置：
   ```
   PRIVATE_KEY=your_private_key
   ENS_REGISTRY_ADDRESS=0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e # 以太坊主网 ENS Registry
   # 可选，如果你已经部署了这些合约
   GATEWAY_VERIFIER_ADDRESS=your_verifier_address
   ```

2. 部署 ENSResolverFactory：
   ```bash
   forge script script/DeployENSResolverFactory.s.sol --rpc-url <your_rpc_url> --broadcast
   ```

### 创建和使用解析器

一旦工厂合约部署好，用户可以：

1. 调用 `createResolver(string name)` 创建自己的解析器
2. 使用 `getUserResolvers(address user)` 获取用户创建的所有解析器
3. 在创建的解析器上设置各种 ENS 记录

## 开发

### 编译合约

```bash
forge build
```

### 运行测试

```bash
forge test
```

### 测试特定合约

```bash
forge test --match-contract ENSResolverFactoryTest -vv
```

## 文档

- [FEATURES.md](FEATURES.md) - 详细功能列表
- [CHANGES.md](CHANGES.md) - 版本历史和变更记录
- [CONTRACT_RELATIONS.md](CONTRACT_RELATIONS.md) - 合约关系和架构说明

## 许可证

MIT
