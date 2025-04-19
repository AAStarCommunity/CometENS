# CometENS
Now we upgrade ENS to support CCIP-read based on offchain resolver on Optimism Layer2.

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
In long term, we will follow the ENSV2 roadmap:https://roadmap.ens.domains/l2-roadmap/.

## How to use
### Free second level domain registry
Free for all users: register your favorite domain name and use it.


# ENS Offchain Resolver Gateway(deprecated)
This package implements a simple CCIP-read gateway server for ENS offchain resolution.

## Usage:
You can run the gateway as a command line tool; in its default configuration it reads the data to serve from a JSON file specified on the command line:

```
yarn && yarn build
yarn start --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --data test.eth.json
```

`private-key` should be an Ethereum private key that will be used to sign messages. You should configure your resolver contract to expect messages to be signed using the corresponding address.

`data` is the path to the data file; an example file is provided in `test.eth.json`.

## Customisation
The JSON backend is implemented in [json.ts](src/json.ts), and implements the `Database` interface from [server.ts](src/server.ts). You can replace this with your own database service by implementing the methods provided in that interface. If a record does not exist, you should return the zero value for that type - for example, requests for nonexistent text records should be responded to with the empty string, and requests for nonexistent addresses should be responded to with the all-zero address.

For an example of how to set up a gateway server with a custom database backend, see [index.ts](src/index.ts):
```
const signer = new ethers.utils.SigningKey(privateKey);

const db = JSONDatabase.fromFilename(options.data, parseInt(options.ttl));

const app = makeApp(signer, '/', db);
app.listen(parseInt(options.port));
```
