# ENS Layer2 解析项目开发计划

## 项目概述

构建一个完整的ENS域名L2解析解决方案，利用Unruggable Gateways技术实现安全、高效的域名解析。

## 开发阶段

### 阶段1：基础合约开发 [已完成]

1. ✅ 实现StorageContract合约
   - 存储域名解析数据的核心合约
   - 实现各种记录类型的存储功能

2. ✅ 实现ENSManager合约
   - 管理子域名注册
   - 管理域名解析设置
   - 实现权限控制

3. ✅ 实现OPResolver合约
   - 通过Unruggable Gateways获取L2数据
   - 实现标准ENS解析接口

### 阶段2：部署脚本开发 [已完成]

1. ✅ 实现L2合约部署脚本
   - 部署ENSRegistry
   - 部署StorageContract
   - 部署ENSManager

2. ✅ 实现L1合约部署脚本
   - 部署GatewayVM
   - 部署VerifierHooks
   - 部署OPFaultVerifier
   - 部署OPResolver

3. ✅ 实现Resolver设置脚本
   - 在ENS Registry中设置OPResolver

### 阶段3：测试开发 [已完成]

1. ✅ 实现StorageContract单元测试
2. ✅ 实现ENSManager单元测试
3. ✅ 实现端到端解析测试脚本

### 阶段4：增强功能开发 [已完成]

1. ✅ 实现ENSResolverFactory合约
   - 创建和管理ENSResolver实例
   - 提供所有者管理功能
   - 追踪已创建的Resolver

2. ✅ 实现ENSResolverFactory部署脚本
3. ✅ 实现ENSResolverFactory单元测试
4. ✅ 创建合约关系文档

### 阶段5：前端开发 [进行中]

1. ✅ 克隆ENS App v3作为基础
2. ✅ 开发钩子和组件
   - 实现L2解析钩子
   - 实现子域名注册组件
3. 🔄 精简ENS App，适配L2解析需求
4. ⬜ 开发域名管理界面
5. ⬜ 添加多语言支持

### 阶段6：集成与部署 [待开始]

1. ⬜ 配置测试网部署
   - 在Optimism Sepolia测试网部署L2合约
   - 在Sepolia测试网部署L1合约
   - 设置测试网ENS Resolver

2. ⬜ 测试网测试与优化
   - 验证端到端解析功能
   - 验证子域名注册功能
   - 性能优化与测试

3. ⬜ 准备主网部署
   - 编写部署文档
   - 准备主网部署流程
   - 安全审计

## 时间线规划

- 阶段1：基础合约开发 - 1周 [完成]
- 阶段2：部署脚本开发 - 1周 [完成]
- 阶段3：测试开发 - 1周 [完成]
- 阶段4：增强功能开发 - 1周 [完成]
- 阶段5：前端开发 - 2周 [第1周]
- 阶段6：集成与部署 - 2周 [待开始]

## 当前优先任务

1. 完成前端组件开发
2. 精简ENS前端应用，移除不需要的复杂功能
3. 准备测试网部署 