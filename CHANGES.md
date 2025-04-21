# ENS Layer2 解析项目更新日志

## 版本 0.1.0 (初始开发)

### 2023-11-15

- 项目初始化
- 创建基础文件结构
- 添加ENS合约依赖

## 版本 0.2.0 (合约开发)

### 2023-11-18

- 实现StorageContract合约
  - 添加域名数据存储功能
  - 实现多种记录类型存储
  - 添加事件触发

- 实现ENSManager合约
  - 实现子域名注册功能
  - 实现域名解析设置功能
  - 添加权限控制

## 版本 0.3.0 (解析器开发)

### 2023-11-22

- 实现OPResolver合约
  - 集成Unruggable Gateways
  - 实现ENS解析接口
  - 添加L2数据获取逻辑

## 版本 0.4.0 (部署脚本)

### 2023-11-25

- 创建L2部署脚本
  - 部署ENSRegistry
  - 部署StorageContract
  - 部署ENSManager

- 创建L1部署脚本
  - 部署GatewayVM
  - 部署VerifierHooks
  - 部署OPFaultVerifier
  - 部署OPResolver

- 创建Resolver设置脚本
  - 设置ENS Resolver

## 版本 0.5.0 (测试开发)

### 2023-11-28

- 实现StorageContract测试
  - 测试数据存储功能
  - 测试权限控制

- 实现ENSManager测试
  - 测试子域名注册
  - 测试解析设置
  - 测试权限检查

- 创建端到端测试脚本
  - 测试完整解析流程

## 版本 0.6.0 (前端开发开始)

### 2023-12-05

- 克隆ENS App v3作为基础
- 配置项目结构
- 更新依赖项

## 版本 0.7.0 (前端组件开发)

### 2023-12-08

- 创建useL2Resolver钩子
  - 实现域名解析功能
  - 添加错误处理

- 创建RegisterSubdomain组件
  - 实现子域名注册UI
  - 添加表单验证

## 版本 0.8.0 (前端开发继续)

### 2023-12-12

- 添加Cursor规则配置
- 更新.gitignore配置，增加前端特定忽略项
- 创建ENS Layer2解析项目结构说明
- 增加SetupResolver.s.sol脚本，用于在L1设置ENS域名Resolver
- 增加test-resolution.ts测试脚本，用于测试端到端域名解析

## 版本 0.9.0 (文档更新)

### 2023-12-15

- 创建FEATURES.md文件，定义项目功能需求
- 创建PLAN.md文件，规划开发进度
- 创建CHANGES.md文件，记录项目变更
- 更新项目README.md，增加项目说明和使用指南 

## 版本 0.10.0 (解析器工厂开发)

### 2024-07-15

- 实现ENSResolverFactory合约
  - 添加创建ENSResolver实例的功能
  - 实现用户解析器管理
  - 添加所有权转移机制
  - 提供解析器查询功能

- 创建DeployENSResolverFactory.s.sol部署脚本
  - 支持从.env读取配置
  - 支持使用已存在的GatewayVerifier
  - 记录部署地址到deployments目录

- 实现ENSResolverFactory测试
  - 测试创建解析器功能
  - 测试多用户场景
  - 测试配置更新功能

- 修改内容总结:
  - 新增文件: contracts/ENSResolverFactory.sol
  - 新增文件: script/DeployENSResolverFactory.s.sol
  - 新增文件: test/ENSResolverFactory.t.sol 

## 版本 0.11.0 (测试修复)

### 2024-07-20

- 修复测试用例中的权限问题
  - 更新ENSManager.t.sol以正确设置域名所有权
  - 更新StorageContract.t.sol中的注册子域名权限检查
  - 添加管理员权限检查到registerSubdomain函数

- 优化合约注释
  - 将ENSManager合约中的中文注释改为英文
  - 规范化注释格式，提高代码可读性

- 修改内容总结:
  - 更新文件: test/ENSManager.t.sol
  - 更新文件: test/StorageContract.t.sol
  - 更新文件: contracts/StorageContract.sol
  - 更新文件: contracts/ENSManager.sol
  - 更新文件: PLAN.md 

## 0.11.0 (2024-07-20)

### 测试修复和权限检查优化

#### 修复内容
- 修复测试用例关于权限问题的处理：
  - 更新 `test/ENSManager.t.sol` 确保正确的域名所有权设置
  - 更新 `test/StorageContract.t.sol` 添加子域名注册的权限检查
  - 完善管理员权限检查的测试用例，提高测试覆盖率

#### 变更的文件
- test/ENSManager.t.sol: 修改测试域名哈希和权限检查方式
- test/StorageContract.t.sol: 添加权限检查测试，优化测试结构

### 技术细节
- 解决了测试中 "Not authorized for parent domain" 的错误，通过确保在测试环境中正确设置域名所有权和管理员权限
- 更新了测试断言，使用vm.expectRevert来验证权限检查功能
- 移除了 ENSRegistry.sol 的依赖引用问题，避免编译错误

### 注意事项
- 所有测试文件中的注释已从中文转为英文，提高代码可读性
- 测试前确保已安装必要的依赖 