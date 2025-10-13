# CometENS 设计文档 (V3 - 最终版)

## 1. 产品设计

(与 V2 版本一致，核心是基于 ERC-1155 的子域名 NFT，提供 DID 和 DAPI 指向功能)

### 1.1. 核心愿景

CometENS 旨在成为一个开源、去中心化的 ENS 子域名分发和管理框架。它使任何拥有根域名（如 `aastar.eth`）的组织或个人，能够轻松地向其社区成员或用户分发二级或三级域名（如 `alice.aastar.eth`），并赋予这些子域名作为真正数字资产的应用价值。

### 1.2. 核心功能（支持Lyaer1,主要服务Layer2）

1.  **子域名即 NFT (ERC-1155)**
2.  **多链地址解析**
3.  **去中心化身份 (DID) 和社交图谱**
4.  **DAPI (去中心化服务) 指向**

### 1.3. 目标用户

1.  **Web3 项目方/社区**
2.  **DApp 开发者**
3.  **普通 Web3 用户**

---

## 2. 技术框架分析

### 2.1. 核心架构：Name Wrapper (L2) + CCIP-Read (L1)

最终架构融合了 Name Wrapper 和 CCIP-Read 两个核心方案，实现了“L2 管理所有权与记录，L1 安全低成本解析”的目标。

```mermaid
graph TD
    subgraph "用户端"
        A[前端 (React + Vite)]
    end

    subgraph "链下服务 (Off-Chain)"
        B[后端 Gateway (TypeScript on Cloudflare Workers)]
        C[Worker EOA]
    end

    subgraph "Layer 1 (主网)"
        G[ENS 注册表]
        H(CometENS L1 Resolver) -- "CCIP-Read" --> B
    end

    subgraph "Layer 2 (Optimism)"
        D[ENS Name Wrapper]
        E[Public Resolver]
        F[ERC-4337 Paymaster]
    end

    U[用户 Wallet] <--> A
    A -- "1. 签名授权" --> B
    B -- "2. 验证, 查询L2, 构建Tx" --> C
    C -- "3. 调用L2合约 (Sponsored Tx)" --> D
    C -- "via" --> F
    D -- "设置所有者/记录" --> E
    G -- "解析 aastar.eth" --> H

    style D fill:#f9f,stroke:#333,stroke-width:2px
    style E fill:#f9f,stroke:#333,stroke-width:2px
```

### 2.2. 关键组件详解

1.  **L1 合约 (`CometENS_L1_Resolver`)**: 部署在以太坊主网，作为 `aastar.eth` 的解析器。它实现了 CCIP-Read 协议，收到解析请求后，会返回指向后端 Gateway 的 URL，并将从 Gateway 返回的带签名数据进行验证。

2.  **L2 合约 (官方)**: 我们将完全依赖部署在 Optimism 上的官方 `ENS Name Wrapper` 和 `Public Resolver` 合约来管理子域名 NFT 的所有权和记录。

3.  **后端 Gateway (Cloudflare Worker)**: 核心链下服务。负责响应来自 L1 解析器的 CCIP-Read 请求。它会查询 L2 上的 Name Wrapper 和 Public Resolver，获取真实数据，然后用 Worker EOA 签名并返回。

4.  **前端 (Vite App)**: 用户交互界面，负责连接钱包、引导签名、与后端通信。

5.  **Worker EOA**: 由后端服务控制的链上执行账户，负责支付 Gas 并将用户的意图（注册、设置记录）通过调用 L2 的 Name Wrapper 合约来执行。

### 2.3. 账户与交易模型

将分阶段实现：
*   **第一阶段**: 仅支持 EOA (MetaMask) 用户。用户通过 EIP-712 签名授权，由后端 Worker EOA 代理执行并支付 Gas。
*   **第二阶段**: 增加对 ERC-4337 账户的支持，通过 Paymaster 实现 AA 用户的 Gasless 体验。同时探索 EIP-7702 为 EOA 用户提供备选的 Gasless 方案。

---

## 3. 安全考量：信任根漏洞与缓解方案

### 3.1. 风险描述

本架构的“信任根”在于 L1 上的 `aastar.eth` 域名。其所有者有权在 L1 ENS 注册表中更改 `aastar.eth` 的解析器。如果所有者作恶，将解析器从我们的 `CometENS_L1_Resolver` 更换为恶意地址，整个子域名生态的 L1 解析路径将会中断，导致所有子域名资产价值受损。

### 3.2. 推荐解决方案：在 L1 烧断保险丝 (Fuse)

为了提供基于代码的、永久的信任承诺，建议 `aastar.eth` 的所有者执行以下一次性操作：

1.  在 **以太坊主网 (L1)** 上，将 `aastar.eth` 域名本身用 **L1 的 Name Wrapper** 包裹起来。
2.  调用 L1 Name Wrapper 的 `setFuses` 函数，永久性地烧断 (burn) `CANNOT_SET_RESOLVER` 这个保险丝。

此操作不可逆，将从技术上保证 `aastar.eth` 的 L1 解析器地址被永久锁定，任何人（包括所有者自己）都无法再更改，从而一劳永逸地解决了信任根风险。

---

## 4. 核心场景时序图

(与 V2 版本一致)

#### 场景 1: 社区管理员初始化

```mermaid
sequenceDiagram
    participant Admin as 社区管理员 (EOA)
    participant Wrapper as ENS Name Wrapper

    Admin->>Wrapper: 1. 调用 wrap(aastar.eth)
    activate Wrapper
    Wrapper-->>Admin: 2. aastar.eth 被包裹
    deactivate Wrapper
```

#### 场景 2: 最终用户注册子域名

```mermaid
sequenceDiagram
    participant User as 最终用户 (EOA/AA)
    participant FE as 前端 (Vite)
    participant BE as 后端 (Cloudflare Worker)
    participant Worker as Worker EOA
    participant Wrapper as ENS Name Wrapper (L2)

    User->>FE: 1. 连接钱包, 输入 "alice"
    FE->>User: 2. 请求签名授权
    User->>FE: 3. 签名 (EIP-712 或 UserOp)
    FE->>BE: 4. 发送 {域名, 签名}
    activate BE
    BE->>BE: 5. 验证签名
    BE->>Worker: 6. 指令: 为User注册'alice.aastar.eth'
    deactivate BE
    activate Worker
    Worker->>Wrapper: 7. 调用 setSubnodeOwner(...)
    activate Wrapper
    Wrapper-->>Worker: 8. 成功, NFT 已铸造给 User
    deactivate Wrapper
    Worker-->>BE: 9. 返回交易结果
    deactivate Worker
```

#### 场景 3: DApp 开发者使用子域名

```mermaid
sequenceDiagram
    participant DApp as 外部 DApp
    participant ENSRegistry as ENS 注册表 (L1)
    participant L1Resolver as CometENS L1 Resolver

    DApp->>ENSRegistry: 1. resolve("bob.paymaster.aastar.eth")
    activate ENSRegistry
    ENSRegistry-->>DApp: 2. 返回解析器地址 (L1Resolver)
    deactivate ENSRegistry

    DApp->>L1Resolver: 3. addr("bob.paymaster.aastar.eth")
    activate L1Resolver
    L1Resolver-->>DApp: 4. Revert OffchainLookup(指向Gateway)
    deactivate L1Resolver
```
