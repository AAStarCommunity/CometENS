# CometENS V2
Now we upgrade CometENS to support CCIP-read based on offchain resolver on Optimism Layer2.

## System overview
1. Resolve ENS domain to address
2. Register subdomain
3. Set subdomain resolution address
4. Resolve subdomain on Layer2 (e.g., Optimism)
5. Set text record
6. Set Content Hash (for decentralized websites, e.g., IPFS)
7. Set ENS avatar
8. Set contract name (associate with smart contract)
9. Set multichain address (e.g., set address for Bitcoin or Polygon)



## What do CometENS bring to users?

### 好记好用的加密账户
例如jason.aastar.eth
→ 需油册即新增Account
→ 要积分在你栏里
→ 完成任务获得
→ 打入Email 账号（未绑定）
→ 创建ENS 和帐户（地址）
 
### Features
1. 对用户：多链统一地址：   jason.aastar.eth
2. 对开发者：统一的SDK去中心接口：plancker.aastar.eth,获得text record(API list)
具体特性：
 
1. 二级域 1155 Token归属于你，可管理，提供签名。（以社区为单位）
2. 多链地址一码，主网 jason.aa → 可计算，不部署。
3. 持有域名，就是持有币
- OP.jason.aa.eth
- Arb.jason.aa.eth → 可先转账再部署
4. binding：和地址绑定，合约地址可换私钥，地址不变。
- 有个油本，发行或买断，要充值到 被换用的Account。
5. 更换过程中的资金不会丢失，缺要转账？
6. 私钥丢失，受控
- 只能转出到几个地址
- 只能由指定的
- 只能旧版恢复
 
钱包地址
导入为很
自主签名ENS
多链地址
交互站里储存（要充值）
去中心网站（2PF5, 未来转）
默认合约账户，为安全兼容/收费。
绑定web3/EOA 于网站登录，API
默认登录集成指纹支付。支付积分（官方服务器）
 


## Our solution
In medium term, we will follow ENS official suggestion: deploy a gateway server that implements a simple CCIP-read gateway server for ENS offchain resolution.
In long term, we will follow the [ENSV2 roadmap](https://roadmap.ens.domains/l2-roadmap/).
We use ethers.js V6 and wagmiV2 的ENS domain operate, reference from [ENS official SDK documentation](https://docs.ens.domains/web/quickstart).

## How to use

### Initiate
```
pnpm create vite comet-ens
# 选择 react 或 react-ts 模板

pnpm add ethers wagmi
pnpm add react@19 react-dom@19 typescript@latest -D
```
### Free second level domain registry
Free for all users: register your favorite domain name and use it.





### 代码说明
1. **依赖和初始化**：
   - 使用`ethers.js`处理与以太坊区块链的交互，`wagmi`提供React钩子简化ENS操作。
   - ENS注册表地址为固定主网地址，Layer2解析器地址需根据实际网络（如Optimism）替换。

2. **核心功能**：
   - **解析ENS域名**：通过`provider.resolveName`将`aastar.eth`解析为以太坊地址。
   - **注册子域名**：使用ENS注册表合约的`setSubnodeOwner`方法为`jason.aastar.eth`分配拥有者。
   - **设置子域名解析**：通过解析器合约的`setAddr`方法为子域名设置解析地址。
   - **Layer2解析**：连接Optimism网络，查询子域名在Layer2上的解析地址。
   - **设置文本记录**：为`aastar.eth`设置文本记录（如URL），支持`jason.aastar.io`的关联。

3. **注意事项**：
   - 运行代码前需安装依赖：`npm install ethers wagmi react`。
   - 配置MetaMask等钱包，连接到以太坊主网或Optimism网络。
   - Layer2解析需要正确的Optimism RPC URL和解析器地址。
   - 确保拥有`aastar.eth`的控制权，否则注册子域名会失败。
   - 交易需支付Gas费用，测试时建议使用测试网（如Sepolia）。

4. **参考文档**：
   - ENS官方文档提供了详细的API说明，代码中使用了`namehash`和解析器相关功能。
   - Wagmi的钩子（如`useEnsResolver`、`useEnsName`）简化了ENS查询。
   - 更多细节可参考：
     - https://docs.ens.domains/web/resolution
     - https://docs.ens.domains/web/subdomains
     - https://docs.ens.domains/web/multichain

如需进一步调整（如支持其他Layer2网络或添加头像功能），请告诉我！