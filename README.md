<p align="center">
    <img src="https://raw.githubusercontent.com/unruggable-labs/unruggable-gateways-ens-resolution-demos/main/unruggable-logo-black.png" style = "width:300px;" alt = "Unruggable Gateways" />
<img src="https://raw.githubusercontent.com/jhfnetboy/MarkDownImg/main/img/202504211257163.png" alt = "CometENS from   AAStar"/>    
</p>

# ENS Layer2 解析项目

一个基于Optimism Layer2的ENS域名解析解决方案，使用Unruggable Gateways技术确保数据安全可验证。

## 项目概述

本项目实现了一个完整的ENS域名Layer2解析系统，允许用户在Optimism上管理ENS域名，同时在以太坊主网上提供标准的解析服务。通过使用Unruggable Gateways技术，我们确保了Layer2数据可以被Layer1安全验证，从而实现了高效且安全的域名解析方案。

### 主要功能

- 在Optimism上存储和管理ENS域名数据
- 在以太坊主网上解析指向Optimism的ENS域名
- 注册和管理子域名
- 设置各种记录类型（地址、文本、内容哈希等）
- 前端界面用于域名管理和解析

## 安装

### 前置条件

- Node.js >= 16
- Bun >= 1.0
- Foundry (Forge, Cast, Anvil)

### 克隆仓库

```bash
git clone https://github.com/your-username/unruggable-gateways-ens-resolution-demos.git
cd unruggable-gateways-ens-resolution-demos
```

### 安装依赖

```bash
bun install
forge install
```

## 合约开发与测试

### 编译合约

```bash
forge build
```

### 运行测试

```bash
forge test -vv
```

### 部署合约

1. 首先，创建一个`.env`文件并设置所需环境变量：

```
PRIVATE_KEY=your_private_key
OPTIMISM_RPC_URL=your_optimism_rpc_url
ETHEREUM_RPC_URL=your_ethereum_rpc_url
ENS_ROOT_NAME=your_ens_name.eth
```

2. 部署L2合约：

```bash
forge script script/DeployL2Contracts.s.sol --rpc-url $OPTIMISM_RPC_URL --broadcast
```

3. 部署L1合约：

```bash
forge script script/DeployL1Contracts.s.sol --rpc-url $ETHEREUM_RPC_URL --broadcast
```

4. 设置Resolver：

```bash
forge script script/SetupResolver.s.sol --rpc-url $ETHEREUM_RPC_URL --broadcast
```

## 前端开发

### 运行前端

```bash
cd frontend
pnpm install  # 或 npm install
pnpm dev      # 或 npm run dev
```

### 构建前端

```bash
cd frontend
pnpm build    # 或 npm run build
```

## 测试解析

运行端到端测试脚本，测试域名解析：

```bash
bun test-resolution.ts
```

## 项目结构

- `contracts/`: 智能合约源代码
  - `StorageContract.sol`: L2数据存储合约
  - `ENSManager.sol`: L2域名管理合约
  - `OPResolver.sol`: L1域名解析合约
- `script/`: 部署脚本
  - `DeployL2Contracts.s.sol`: L2合约部署脚本
  - `DeployL1Contracts.s.sol`: L1合约部署脚本
  - `SetupResolver.s.sol`: Resolver设置脚本
- `test/`: 测试文件
  - `StorageContract.t.sol`: 存储合约测试
  - `ENSManager.t.sol`: 管理合约测试
- `frontend/`: 前端应用
  - `src/`: 前端源代码
    - `hooks/`: React钩子
    - `components/`: React组件

## 文档

- [FEATURES.md](FEATURES.md): 功能列表
- [PLAN.md](PLAN.md): 开发计划
- [CHANGES.md](CHANGES.md): 变更记录

## 许可证

MIT