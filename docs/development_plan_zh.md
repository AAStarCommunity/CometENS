# CometENS 开发计划 (V2)

本文档基于 V3 版设计文档，将项目开发分解为多个阶段。

---

## 核心依赖与来源

在开发前，明确核心智能合约的来源、获取方式和我们的使用策略。

#### 1. `CometENS_L1_Resolver` (我方部署)
- **策略**: 我们将使用项目自带的官方模板进行编译和部署。
- **代码来源**: 使用我们项目中已有的 `contracts/OffchainResolver.sol` 文件 (继承自 `unruggable-gateways`)。
- **ABI 来源**: 使用 `foundry` 编译我们自己的合约代码后，在 `out/` 目录中获得。
- **地址来源**: 在我们手动将其部署到 L1 测试网/主网后获得。

#### 2. `ENS Name Wrapper` (官方部署)
- **策略**: 我们不部署此合约，而是直接与 ENS 团队部署在链上的官方合约进行交互。
- **代码来源**: 无需关心源码。
- **ABI 来源**: 通过 `pnpm add @ensdomains/ens-contracts` 命令安装官方包，并从包中导入 ABI。
- **地址来源**: 从 ENS 官方文档查询并硬编码到我们后端配置中。

#### 3. `Public Resolver` (官方部署)
- **策略**: 与 Name Wrapper 相同，我们直接与官方部署的合约交互。
- **ABI 来源**: 同样来自 `@ensdomains/ens-contracts` 包。
- **地址来源**: 从 ENS 官方文档查询。

---

## Phase 0: 同步与基线运行 (Synchronization & Baseline Run)

*   **目标**: 确保代码库最新，并成功在本地跑通原始的 `unruggable-gateways` Demo。
*   **任务**:
    1.  **同步代码**: 将 `main` 分支的最新代码合并到我们当前的 `aastar-dev` 分支。
    2.  **安装依赖**: 执行 `pnpm install`，并安装合约依赖 `@ensdomains/ens-contracts`。
    3.  **深入分析**: 详细阅读 `unruggable-gateways` 的合约、后端 Gateway 服务和前端 Demo 的源码。
    4.  **运行 Demo**: 在本地测试网（如 Foundry Anvil）上，完整部署并跑通原始 Demo 的全流程。

## Phase 1: CometENS 核心改造 (MVP)

*   **目标**: 将原始 Demo 改造为我们的 CometENS 产品 MVP。
*   **任务**:
    1.  **后端改造**: 修改 Gateway 服务，将其数据源从 JSON 文件切换为从 L2 的 `ENS Name Wrapper` 合约进行实时读取。
    2.  **前端改造**: 界面品牌化，并实现用户签名授权 -> 后端代理注册的流程。
    3.  **后台执行逻辑改造**: 实现 Worker EOA 通过调用 L2 `ENS Name Wrapper` 为用户铸造子域名 NFT 的逻辑。

## Phase 2: 功能增强与部署

*   **目标**: 增加域名管理功能，并部署到公共测试网。
*   **任务**:
    1.  **域名管理**: 开发前端页面，允许用户管理自己名下的子域名（设置地址、头像等）。
    2.  **公共测试网部署**: 将所有改造后的组件部署到 Sepolia 和 OP Sepolia，进行公开测试。

## Phase 3: 高级功能与主网

*   **目标**: 支持 AA 账户，上线主网，并完成安全加固。
*   **任务**:
    1.  **AA 账户支持**: 集成 ERC-4337 Paymaster，实现对 AA 钱包的 Gasless 支持。
    2.  **主网部署**: 在以太坊主网和 Optimism 主网进行部署。
    3.  **(管理操作) 安全加固**: 由 `aastar.eth` 所有者执行 L1 Name Wrapper 的“熔断”操作，永久锁定解析器。